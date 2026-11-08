import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/**
 * One-line plain-English summary of the bash command being asked about,
 * shown as a widget next to the pi-permission-system dialog.
 * Loads before npm extensions, sees the bash command via `tool_call`,
 * paints on `ui_prompt_start`, clears on `ui_prompt_end`.
 *
 * Look: accent "ⓘ summary" label + natural sentence
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

function wordClip(text: string, maxWords: number) {
  const words = text.split(/\s+/);
  return words.length <= maxWords ? text : words.slice(0, maxWords).join(" ") + "…";
}

const LABEL = "ⓘ summary";
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
  if (line) out.push(line);
  return out.length ? out : [text];
}

export default function (pi: ExtensionAPI) {
  let enabled = true;
  let lastCommand: string | undefined;
  let run = 0;
  let inFlight: AbortController | undefined;
  let placeholderTimer: ReturnType<typeof setTimeout> | undefined;

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

  pi.on("tool_call", async (event) => {
    const input = event.input as { command?: string } | undefined;
    if (event.toolName === "bash" && typeof input?.command === "string") {
      lastCommand = input.command;
    }
  });

  pi.on("ui_prompt_start", async (event, ctx) => {
    if (!enabled || event.kind !== "select") return;
    const title = event.title ?? "";
    const match = /requested bash command '([\s\S]*)' \(matched/.exec(title);
    if (!match) return;
    const command = lastCommand ?? match[1];
    lastCommand = undefined;
    if (!command || command.length <= TRIVIAL_LIMIT) return;

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
          return [theme.fg("dim", "summarizing…")];
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
      ctx.ui.setWidget(WIDGET_KEY, (_tui, theme: Theme) => ({
        render(width: number) {
          // Wrap to terminal width; every line still truncated as a safety net
          // (an over-wide widget line crashes the TUI renderer).
          const labelWidth = visibleWidth(LABEL + GAP);
          // Budget must exclude the label the first line also carries.
          const avail = Math.max(width - labelWidth - 4, 20);
          const chunks = wrapWords(sentence, avail);
          const lines = [`${theme.fg("accent", LABEL)}${GAP}${chunks[0]}`];
          const pad = " ".repeat(labelWidth);
          for (const chunk of chunks.slice(1)) lines.push(`${pad}${chunk}`);
          return lines.map((line) => truncateToWidth(line, width));
        },
        invalidate() {},
      }));
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
  });

  pi.on("ui_prompt_end", async (_event, ctx) => {
    clearPlaceholder();
    run++;
    inFlight?.abort();
    inFlight = undefined;
    ctx.ui.setWidget(WIDGET_KEY, undefined);
  });
}
