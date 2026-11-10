import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/**
 * One-line plain-English summary of the bash command being asked about,
 * shown as a widget above the editor while a permission dialog is up.
 *
 * Works with @gotgenes/pi-permission-system: subscribes to its documented
 * `permissions:ui_prompt` broadcast (pi.events), which fires immediately
 * before the ask's dialog opens and carries the surface/command directly.
 * Also keeps a ui_prompt_start title-parse fallback for older select-style
 * dialogs (the previous pi-permission-system v0.8 wording), and a generic
 * cleanup on ui_prompt_end.
 *
 * Look: accent left bar + "ⓘ summary" label + natural sentence, blank line
 * after (summarizing and final alike) so the prompt/editor doesn't hug it.
 * Summarizes the FULL command line (the tool call's input), since the fork
 * asks per-segment and its dialog's "command" field may show only one
 * segment; repeated asks for the same full command reuse the cached sentence.
 * (User preference: the accent callout over a cloned "Summary      :" field
 * row, after trying both.)
 *
 * Config:
 * - alt+s toggles summaries on/off at runtime (notified, not persisted).
 * - PI_CMD_SUMMARY_MODEL="provider/id" (e.g. "ollama/qwen3.5:4b") uses a
 *   cheaper summarizer model instead of the current model; unknown ids
 *   fall back to the current model.
 */

const WIDGET_KEY = "cmd-summary";
const PLACEHOLDER_DELAY_MS = 700; // dialog is fully composed by then
// Slightly over-generate so wordClip never cuts mid-idea; the LLM already
// aims at ~30 words, and the widget wraps long sentences anyway.
const MAX_SENTENCE_WORDS = 55;
const TRIVIAL_LIMIT = 24; // skip unambiguous tiny commands
const TIMEOUT_MS = 8_000;

const SYSTEM_PROMPT =
  "You explain shell commands on a permission dialog in one short natural sentence. " +
  "Reply with a single sentence, under 24 words: no markdown, no quotes, no preamble. " +
  "Start with a capital letter, describe the effects in execution order joined by commas or 'then', " +
  "and end with a period. " +
  "Example: 'Sets JAVA_HOME, lists installed SDK packages, then checks disk usage of the SDK dir.'";

interface PermissionsUiPromptEvent {
  surface?: string | null;
  value?: string | null;
  request?: { toolName?: string | null } | null;
}

/** Accent-callout widget for a summary sentence. */
function summaryWidget(sentence: string) {
  return (_tui: unknown, theme: Theme) => ({
    render(width: number) {
      // Left accent bar; wrapped lines align under the sentence start.
      // Wrap to terminal width; every line still truncated as a safety net
      // (an over-wide widget line crashes the TUI renderer).
      const bar = theme.fg("accent", BAR);
      const textStart = visibleWidth(LABEL) + visibleWidth(GAP); // first line
      const avail = Math.max(width - visibleWidth(BAR) - textStart - 1, 20);
      const chunks = wrapWords(sentence, avail);
      const lines = [
        `${bar}${theme.fg("accent", LABEL)}${GAP}${chunks[0]}`,
      ];
      const contPad = " ".repeat(visibleWidth(BAR) + textStart);
      for (const chunk of chunks.slice(1)) lines.push(`${bar}${contPad}${chunk}`);
      // Trailing blank line keeps the editor from hugging this text.
      return [...lines.map((line) => truncateToWidth(line, width)), ""];
    },
    invalidate() {},
  });
}

function wordClip(text: string, maxWords: number) {
  const words = text.split(/\s+/);
  return words.length <= maxWords ? text : words.slice(0, maxWords).join(" ") + "…";
}

const LABEL = "ⓘ summary";
const BAR = "▌";
const GAP = "  ";

/** Greedy word wrap on visible width (plain text without ANSI codes). */
function wrapWords(text: string, maxWidth: number): string[] {
  const out: string[] = [];
  let line = "";
  for (const word of text.split(/\s+/)) {
    const candidate = line ? `${line} ${word}` : word;
    if (line && visibleWidth(candidate) > maxWidth) {
      out.push(line);
      line = word;
    } else {
      line = candidate;
    }
  }
  if (line) out.push(out.length ? line : text);
  return out;
}

export default function (pi: ExtensionAPI) {
  let enabled = true;
  let lastCommand: string | undefined;
  let lastCtx: ExtensionContext | undefined;
  let run = 0;
  let inFlight: AbortController | undefined;
  let placeholderTimer: ReturnType<typeof setTimeout> | undefined;
  // Single-entry cache: the fork can raise several asks for one tool call
  // (one per segment of a compound command); the full command is the same,
  // so the model only runs once for it.
  let cachedCommand: string | undefined;
  let cachedSentence: string | undefined;

  const clearPlaceholder = () => {
    if (placeholderTimer !== undefined) {
      clearTimeout(placeholderTimer);
      placeholderTimer = undefined;
    }
  };

  pi.registerShortcut("alt+s", {
    description: "Toggle bash command summaries (cmd-summary)",
    handler: async (ctx) => {
      enabled = !enabled;
      if (!enabled) {
        clearPlaceholder();
        inFlight?.abort();
        inFlight = undefined;
        ctx.ui.setWidget(WIDGET_KEY, undefined);
      }
      ctx.ui.notify(`cmd-summary ${enabled ? "ON" : "OFF"}`);
    },
  });

  // Fires on every tool call and always precedes any ask about it — the
  // place to capture both the command and the context (the fork's broadcast
  // handler receives no context of its own).
  pi.on("tool_call", async (event, ctx) => {
    lastCtx = ctx;
    const input = event.input as { command?: string } | undefined;
    if (event.toolName === "bash" && typeof input?.command === "string") {
      lastCommand = input.command;
    }
  });

  async function startSummary(command: string, ctx: ExtensionContext) {
    // Repeated ask for the same full command (the fork asks per-segment):
    // replay the cached sentence instead of re-running the model.
    if (command === cachedCommand && cachedSentence !== undefined) {
      clearPlaceholder();
      run++;
      ctx.ui.setWidget(WIDGET_KEY, summaryWidget(cachedSentence));
      return;
    }

    // Configured summarizer model wins; anything unresolvable falls back
    // to the current session model.
    let model = ctx.model ?? ctx.scopedModels[0]?.model;
    const pref = process.env.PI_CMD_SUMMARY_MODEL;
    if (pref) {
      const slash = pref.indexOf("/");
      const found =
        slash > 0
          ? ctx.modelRegistry.find(pref.slice(0, slash), pref.slice(slash + 1))
          : undefined;
      if (found) model = found;
    }
    if (!model) return;

    const id = ++run;
    const ac = new AbortController();
    clearPlaceholder();
    inFlight?.abort();
    inFlight = ac;
    // Hard cap: a slow/throttled model just means no summary, never a stuck widget.
    const timer = setTimeout(() => ac.abort(), TIMEOUT_MS);
    ac.signal.addEventListener("abort", () => clearTimeout(timer), { once: true });
    const signal =
      ctx.signal && typeof AbortSignal.any === "function"
        ? AbortSignal.any([ac.signal, ctx.signal])
        : ac.signal;

    // Placeholder only after a grace period, so it cannot collide with the
    // dialog's opening render. Replaced by the real summary when it resolves.
    placeholderTimer = setTimeout(() => {
      if (id !== run) return;
      ctx.ui.setWidget(WIDGET_KEY, (_tui, theme: Theme) => ({
        render() {
          // Trailing blank line keeps the editor from hugging this text.
          return [theme.fg("dim", "summarizing…"), ""];
        },
        invalidate() {},
      }));
    }, PLACEHOLDER_DELAY_MS);

    const show = (sentence: string | undefined) => {
      if (id !== run) return;
      if (!sentence) {
        ctx.ui.setWidget(WIDGET_KEY, undefined);
        return;
      }
      cachedCommand = command;
      cachedSentence = sentence;
      ctx.ui.setWidget(WIDGET_KEY, summaryWidget(sentence));
    };

    try {
      const res = await ctx.modelRegistry.complete(
        model,
        {
          systemPrompt: SYSTEM_PROMPT,
          messages: [{ role: "user", content: command, timestamp: Date.now() }],
        },
        { maxTokens: 120, signal, sessionId: ctx.sessionManager.getSessionId() }
      );
      clearTimeout(timer);
      clearPlaceholder();

      const stop = res.stopReason ?? "unknown";
      if (id !== run || stop === "aborted") return;
      if (stop === "error") {
        show(undefined); // fail silent: no summary is the natural degradation
        return;
      }

      const text = res.content
        .filter((c) => c.type === "text")
        .map((c) => c.text.trim())
        .join(" ")
        .replace(/\s+/g, " ")
        .trim();
      show(text ? wordClip(text, MAX_SENTENCE_WORDS) : undefined);
    } catch {
      clearTimeout(timer);
      clearPlaceholder();
      show(undefined); // aborted (timeout/dialog closed) or failed — stay silent
    }
  }

  // Primary trigger: the fork's pre-dialog broadcast. The fork asks
  // per-segment for compound commands, so its `value` may be just one
  // segment; prefer the FULL command line captured at tool_call time.
  // For bash asks the top-level `surface` is the display projection
  // ("bash"); for bash asks that gate on a path surface (e.g.
  // external_directory) the full command is still whoever set lastCommand.
  pi.events.on("permissions:ui_prompt", (raw: unknown) => {
    if (!enabled) return;
    const event = raw as PermissionsUiPromptEvent;
    const isBash = event.surface === "bash" || event.request?.toolName === "bash";
    if (!isBash || typeof event.value !== "string" || !event.value) return;
    // Deliberately NOT cleared here: the fork may broadcast per-segment
    // asks within the same tool call, and lastCommand (the full command)
    // must stay alive so every segment summarizes as the full command.
    // The next bash tool_call overwrites it.
    const command = lastCommand ?? (event.surface === "bash" ? event.value : undefined);
    if (!command || command.length <= TRIVIAL_LIMIT) return;
    if (!lastCtx) return;
    void startSummary(command, lastCtx);
  });

  // Fallback: parse the old select-dialog wording, in case a broadcast is
  // missed (older plugin versions, non-TUI select fallbacks).
  pi.on("ui_prompt_start", async (event) => {
    if (!enabled || event.kind !== "select") return;
    const match = /requested bash command '([\s\S]*)' \(matched/.exec(event.title ?? "");
    if (!match) return;
    const command = lastCommand ?? match[1];
    if (!command || command.length <= TRIVIAL_LIMIT) return;
    if (!lastCtx) return;
    await startSummary(command, lastCtx);
  });

  pi.on("ui_prompt_end", async (_event, ctx) => {
    clearPlaceholder();
    run++;
    inFlight?.abort();
    inFlight = undefined;
    ctx.ui.setWidget(WIDGET_KEY, undefined);
  });
}
