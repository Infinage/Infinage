/**
 * toast-notify: desktop notification + chime when Pi needs you but your pane
 * is out of focus.
 *
 * Fires ~/bin/toast (non-blocking notify-send with chime, symlinked from
 * dotfiles/bin) when:
 * - a blocking prompt opens (permission confirm, ask-user question, text
 *   input, editor) -> `ui_prompt_start`, auto-dismisses after 10s
 * - Pi finishes its run and waits for input -> `agent_settled`, auto-dismisses
 *   after 8s
 *
 * Notification content:
 * - finished runs carry a summary: first line of Pi's final reply (captured
 *   from `agent_end`'s messages), or "Run aborted"
 * - permission confirms carry the actual ask: surface + value from
 *   @gotgenes/pi-permission-system's `permissions:ui_prompt` broadcast
 *   (recent-broadcast guard; falls back to the dialog title)
 * - ask-user questions read "Pi needs your input" plus the question title
 *
 * Only fires when the pane is out of focus. Focus is checked in two layers:
 * 1. tmux formats on $TMUX_PANE (pane + window active, session attached)
 * 2. best-effort OS window focus: ask the desktop which window is focused
 *    (hyprctl / swaymsg / xdotool / GNOME / osascript / PowerShell, first
 *    probe that answers wins and is cached) and compare its owning PID
 *    against the terminal's process tree. Catches alt-tabbing to another
 *    app while the tmux pane stays visible. Unknown OS -> degrade to layer 1.
 * Outside tmux with no OS probe, falls back to an OSC 777 desktop notification.
 */

import { spawn, spawnSync } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const NOTE = `${process.env.HOME}/bin/toast`; // -> dotfiles/bin/toast
const COOLDOWN_MS = 2_000; // avoid stacked notifications when events fire together
const AUTO_HIDE_MS = "8000"; // finished-run notifications expire on their own
const STICKY = "10000"; // prompt notifications linger a bit longer, then expire
const PERMISSION_BROADCAST_TTL_MS = 2_000; // staleness guard for the broadcast detail
const PROMPT_WATCH_MS = 2_000; // focus poll interval while a prompt is open
const MAX_DETAIL_CHARS = 90;
let lastNote = 0;

// --- Focus detection ------------------------------------------------------

/** PIDs in the process tree that owns the terminal we run in (terminal
 *  emulator up to pid 1), cached per root pid. */
const treeCache = new Map<number, Set<number>>();

function processTreePids(root: number): Set<number> {
	const cached = treeCache.get(root);
	if (cached) return cached;
	const pids = new Set<number>();
	let cur = root;
	for (let i = 0; i < 50 && cur > 1; i++) {
		pids.add(cur);
		const res = spawnSync("ps", ["-o", "ppid=", "-p", String(cur)], {
			encoding: "utf8",
			timeout: 1_000,
		});
		const ppid = Number(res.stdout?.trim());
		if (!Number.isFinite(ppid) || ppid <= 1) break;
		cur = ppid;
	}
	treeCache.set(root, pids);
	return pids;
}

interface OsProbe {
	name: string;
	cmd: string[];
	pidFrom: (stdout: string) => number | null;
}

function findFocusedPid(node: unknown): number | null {
	if (typeof node !== "object" || node === null) return null;
	const n = node as Record<string, unknown>;
	if (n.focused === true && typeof n.pid === "number") return n.pid;
	for (const key of ["nodes", "floating_nodes"]) {
		const kids = n[key];
		if (!Array.isArray(kids)) continue;
		for (const k of kids) {
			const pid = findFocusedPid(k);
			if (pid !== null) return pid;
		}
	}
	return null;
}

// One probe per platform; the first one that yields a pid is kept. A probe
// that cannot run (missing binary) or fails to parse is skipped, so a GNOME
// machine never gets locked onto gdbus if Eval is blocked, etc.
const OS_PROBES: OsProbe[] = [
	{
		name: "hyprland",
		cmd: ["hyprctl", "activewindow", "-j"],
		pidFrom: (out) => {
			try {
				const pid = (JSON.parse(out) as Record<string, unknown>).pid;
				return typeof pid === "number" && pid > 1 ? pid : null;
			} catch {
				return null;
			}
		},
	},
	{
		name: "sway",
		cmd: ["swaymsg", "-t", "get_tree"],
		pidFrom: (out) => {
			try {
				return findFocusedPid(JSON.parse(out));
			} catch {
				return null;
			}
		},
	},
	{
		name: "x11",
		cmd: ["xdotool", "getactivewindow", "getwindowpid"],
		pidFrom: (out) => {
			const pid = Number(out.trim());
			return Number.isFinite(pid) && pid > 1 ? pid : null;
		},
	},
	{
		// Modern GNOME blocks Eval by default; then this probe simply fails
		// and we degrade to tmux-only focus detection.
		name: "gnome",
		cmd: [
			"gdbus", "call", "--session", "--dest", "org.gnome.Shell",
			"--object-path", "/org/gnome/Shell", "--method", "org.gnome.Shell.Eval",
			"global.display.focus_window.get_pid()",
		],
		pidFrom: (out) => {
			const pid = Number(/\(uint32 (\d+)/.exec(out)?.[1]);
			return Number.isFinite(pid) && pid > 1 ? pid : null;
		},
	},
	{
		name: "macos",
		cmd: [
			"osascript", "-e",
			'tell application "System Events" to get unix id of first application process whose frontmost is true',
		],
		pidFrom: (out) => {
			const pid = Number(out.trim());
			return Number.isFinite(pid) && pid > 1 ? pid : null;
		},
	},
	{
		name: "windows",
		cmd: [
			"powershell", "-NoProfile", "-Command",
			"Add-Type -Namespace W -Name F -MemberDefinition '[DllImport(\"user32.dll\")] public static extern IntPtr GetForegroundWindow(); [DllImport(\"user32.dll\")] public static extern int GetWindowThreadProcessId(IntPtr h, out int p);'; $p = 0; [void][W.F]::GetWindowThreadProcessId([W.F]::GetForegroundWindow(), [ref]$p); $p",
		],
		pidFrom: (out) => {
			const pid = Number(out.trim());
			return Number.isFinite(pid) && pid > 1 ? pid : null;
		},
	},
];

let osProbe: OsProbe | null | undefined; // undefined = not scanned yet, null = none works

/** PID owning the OS-focused window, or null if unknown (no probe / probe
 *  failed / nothing focused). */
function osFocusPid(): number | null {
	if (osProbe === null) return null;
	if (osProbe) {
		const res = spawnSync(osProbe.cmd[0], osProbe.cmd.slice(1), { encoding: "utf8", timeout: 1_000 });
		return res.status === 0 && res.stdout ? osProbe.pidFrom(res.stdout) : null;
	}
	for (const probe of OS_PROBES) {
		const res = spawnSync(probe.cmd[0], probe.cmd.slice(1), { encoding: "utf8", timeout: 1_000 });
		if (res.status !== 0 || !res.stdout) continue;
		const pid = probe.pidFrom(res.stdout);
		if (pid !== null) {
			osProbe = probe;
			return pid;
		}
	}
	osProbe = null;
	return null;
}

/** true = terminal window focused on the desktop, false = another window has
 *  focus, null = cannot tell (no probe, or root pid unresolvable). */
function osWindowFocused(): boolean | null {
	let root: number;
	if (process.env.TMUX_PANE) {
		const res = spawnSync("tmux", ["display-message", "-p", "#{client_pid}"], {
			encoding: "utf8",
			timeout: 1_000,
		});
		const clientPid = Number(res.stdout?.trim());
		if (res.status !== 0 || !Number.isFinite(clientPid) || clientPid <= 1) return null;
		root = clientPid; // tmux client runs inside the terminal's process tree
	} else {
		root = process.pid; // no tmux: we are inside the terminal ourselves
	}
	const tree = processTreePids(root);
	const pid = osFocusPid();
	return pid === null ? null : tree.has(pid);
}

/** true = focused, false = out of focus, null = unknown. Combines tmux-level
 *  focus (pane/window/session) with OS-level focus (terminal vs other apps). */
function paneFocused(): boolean | null {
	const pane = process.env.TMUX_PANE;
	if (!pane) return osWindowFocused();
	const res = spawnSync(
		"tmux",
		["display-message", "-p", "-t", pane, "#{pane_active} #{window_active} #{session_attached}"],
		{ encoding: "utf8", timeout: 2_000 },
	);
	if (res.status !== 0 || !res.stdout) return null;
	const [paneActive, windowActive, attached] = res.stdout.trim().split(/\s+/);
	if (!(paneActive === "1" && windowActive === "1" && Number(attached) > 0)) return false;
	// tmux-visible, but is the terminal window itself focused on the desktop?
	return osWindowFocused() === false ? false : true;
}

/** First line of `text`, hard-truncated with an ellipsis. */
function firstLine(text: string, max = MAX_DETAIL_CHARS): string {
	const line = (text.split("\n", 1)[0] ?? "").trim();
	return line.length > max ? `${line.slice(0, max - 1)}…` : line;
}

function notify(title: string, body: string, expireMs: string = AUTO_HIDE_MS): void {
	const now = Date.now();
	if (now - lastNote < COOLDOWN_MS) return;
	const focused = paneFocused();
	if (focused === true) return; // user is already looking at this pane
	lastNote = now;
	if (focused === false || process.env.TMUX_PANE) {
		// Swallow spawn errors (missing notifier must never crash pi).
		spawn(
			NOTE,
			[`${title}\n${body}`],
			{ stdio: "ignore", detached: true, env: { ...process.env, TOAST_EXPIRE: expireMs } },
		)
			.on("error", () => {})
			.unref();
	} else {
		// No tmux and no OS probe: OSC 777 desktop notification (Ghostty, iTerm2, WezTerm, ...)
		process.stdout.write(`\x1b]777;notify;${title};${body}\x07`);
	}
}

// ask_user_question dialogs surface as kind "custom" with no title (verified
// via debug log), so they share the select label.
const KIND_LABEL: Record<string, string> = {
	select: "Pi needs your input",
	custom: "Pi needs your input",
	confirm: "Permission needed",
	input: "Text input needed",
	editor: "Editor opened",
};

interface PermissionBroadcast {
	surface: string | null;
	value: string | null;
	at: number;
}

export default function (pi: ExtensionAPI) {
	let runSummary: string | undefined; // first line of Pi's final reply
	let lastPermission: PermissionBroadcast | undefined;
	let promptOpen = false; // a blocking ui prompt is currently up
	let promptWatcher: NodeJS.Timeout | undefined;
	let notified = false; // already notified for the current prompt

	// Capture Pi's final reply so agent_settled can say what finished.
	pi.on("agent_end", async (event) => {
		for (let i = event.messages.length - 1; i >= 0; i--) {
			const msg = event.messages[i];
			if (msg?.role !== "assistant") continue;
			const text = msg.content.find((c) => c.type === "text");
			if (text && "text" in text && text.text.trim()) {
				runSummary = firstLine(text.text);
				return;
			}
		}
		runSummary = undefined;
	});

	// @gotgenes/pi-permission-system broadcast: the actual ask (command, path,
	// skill name). Read defensively; emitted right before the dialog opens.
	pi.events.on("permissions:ui_prompt", (raw: unknown) => {
		const event = raw as { surface?: string | null; value?: string | null };
		lastPermission = {
			surface: typeof event.surface === "string" ? event.surface : null,
			value: typeof event.value === "string" ? event.value : null,
			at: Date.now(),
		};
	});

	pi.on("ui_prompt_start", async (event, ctx) => {
		if (ctx.mode !== "tui") return;

		let detail = event.title ?? "";
		if (event.kind === "confirm" && lastPermission && Date.now() - lastPermission.at < PERMISSION_BROADCAST_TTL_MS) {
			const { surface, value } = lastPermission;
			if (value) detail = surface ? `${surface}: ${value}` : value;
			else if (surface) detail = surface;
		}
		if ((event.kind === "select" || event.kind === "custom") && !detail) detail = "on something";
		const body = `${KIND_LABEL[event.kind] ?? "Waiting for you"}\n${firstLine(detail)}`;

		promptOpen = true;
		notified = false;
		clearInterval(promptWatcher);
		const fire = () => {
			if (!promptOpen || notified) return;
			notified = true;
			notify("Pi", body, STICKY); // 10s, not sticky
		};
		if (paneFocused() === false) {
			fire(); // user already away
		} else {
			// Prompt opened while the user was present (e.g. raised at turn
			// start, before they could switch away): watch focus until the
			// prompt is answered and fire the moment they leave.
			promptWatcher = setInterval(() => {
				if (paneFocused() === false) fire();
			}, PROMPT_WATCH_MS);
			promptWatcher.unref();
		}
	});

	pi.on("ui_prompt_end", async () => {
		promptOpen = false;
		clearInterval(promptWatcher);
	});

	pi.on("agent_settled", async (event, ctx) => {
		if (ctx.mode !== "tui") return;
		const summary = runSummary ? ` — ${runSummary}` : "";
		notify("Pi", event.aborted ? `Run aborted${summary}` : `Done${summary || " — waiting for your input"}`);
	});
}
