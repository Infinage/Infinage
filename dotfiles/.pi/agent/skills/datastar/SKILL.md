---
name: datastar
description: Build hypermedia apps with Datastar (data-star.dev), the SSE-driven frontend framework using data-* attributes, signals, and backend-patched HTML. Use whenever the user mentions Datastar, data-star, data-signals, data-on, data-bind, @get/@post actions, datastar-patch-elements, datastar-patch-signals, Rocket web components, or wants server-driven reactive UI with SSE, morphing, or "hypermedia" frontends, even if they don't name Datastar explicitly but are using these attributes. Covers attributes, expressions, actions, SSE event format, Rocket, CSP/security, and the "Tao of Datastar" design philosophy.
---

# Datastar

Hypermedia framework: **backend is the source of truth** and drives the frontend by patching HTML elements and signals over HTTP/SSE. The frontend uses `data-*` attributes for light reactivity. Targets v1.x syntax (colon-keyed attributes like `data-on:click`).

## Reference files (read only when needed)

- `references/attributes.md`: every attribute's modifiers, Pro attributes, casing/aliasing rules
- `references/actions-sse.md`: backend action options, response content types, raw SSE event format
- `references/rocket.md`: Rocket web component API (beta)

## The Tao (follow these unless the user says otherwise)

1. **State lives in the backend.** The frontend is exposed to the user; don't trust or own state there.
2. **Use defaults.** Don't change config options before asking why you need to.
3. **Backend drives the UI** by patching elements and signals.
4. **Signals sparingly.** Only for user interaction (toggle visibility) and sending input to the backend (bound form fields). Fetch current state rather than assuming frontend state is current.
5. **Fat morph.** Send big chunks of DOM (even the whole `<html>`); morphing updates only what changed and preserves state. Skip with `data-ignore-morph`.
6. **Always respond with SSE** (`text/event-stream`). 0..n events per response. Compress (Brotli) streams.
7. **Template on the backend**; use your templating language to stay DRY.
8. **Navigation = anchors/redirects.** Don't manage browser history yourself.
9. **CQRS**: one long-lived `@get` for reads, many short `@post/@put/@delete` for writes.
10. **No optimistic updates.** Show loading indicators, confirm only from the backend.
11. **Accessibility is on you**: semantic HTML, ARIA via `data-attr`, keyboard support.
12. If expressions get complex, you're overcomplicating it. Move logic to the backend or a web component (Rocket). Props down, events up.

## Setup

```html
<script type="module" src="https://cdn.jsdelivr.net/gh/starfederation/datastar@v1.0.4/bundles/datastar.js"></script>
```
(Aliased bundle `datastar-aliased.js` uses `data-star-*` for conflicts with legacy libs. Rocket uses a separate `datastar-rocket.js` bundle that *replaces* datastar.js.)

## Signals and expressions

- Signals are reactive variables, prefixed `$` in expressions: `$foo`, nested `$form.name`.
- Created via `data-signals`, `data-bind`, `data-computed`, `data-indicator`, `data-ref`, or auto-created on use (empty string).
- Signal names: camelCase in expressions; `data-signals:my-signal` -> `$mySignal`. Never contain/begin with `__`.
- Signals starting with `_` are **local**: not sent to the backend by default.
- `el` is the current element in every expression; `evt` in `data-on`; `patch` in `data-on-signal-patch`.
- Expressions are JavaScript: ternary, `&&`, `||`, method calls. Multiple statements need `;` (newlines alone don't separate).
- Actions are prefixed `@`: `@get('/x')`, `@peek(...)`, `@setAll(...)`.

```html
<div data-signals="{count: 0, form: {name: ''}}" data-computed:double="$count * 2">
  <input data-bind:form.name />
  <button data-on:click="$count++; $form.name && @post('/save')">Save</button>
  <span data-text="$double"></span>
</div>
```

## Attribute cheat sheet

| Attribute | Purpose |
|---|---|
| `data-signals:foo="1"` / `data-signals="{foo: 1}"` | Patch signals (`null` removes; `__ifmissing` for defaults) |
| `data-bind:foo` / `data-bind="foo"` | Two-way bind input/select/textarea/web component |
| `data-text="expr"` | Set text content |
| `data-show="expr"` | Toggle visibility (add `style="display:none"` to avoid flash) |
| `data-class:name="expr"` / `data-class="{a: x, 'b-c': y}"` | Toggle classes |
| `data-attr:name="expr"` / `data-attr="{...}"` | Bind any HTML attribute |
| `data-style:prop="expr"` | Bind inline CSS (falsy restores original) |
| `data-computed:foo="expr"` | Read-only derived signal (no side effects!) |
| `data-effect="expr"` | Run on load and when its signals change (side effects) |
| `data-on:event="expr"` | Event listener (`evt` available) |
| `data-init="expr"` | Run when attribute is loaded/patched in |
| `data-indicator:fetching` | Signal true while a fetch is in flight |
| `data-ref:foo` | Signal holding the element |
| `data-on-intersect`, `data-on-interval`, `data-on-signal-patch` | Viewport / timer / signal-change triggers |
| `data-ignore` | Datastar skips element and descendants (`__self` for just the element) |
| `data-ignore-morph` | Backend morphs skip this element |
| `data-preserve-attr="open class"` | Keep attrs across morphs |
| `data-json-signals` | Debug: show all signals (`{include: /re/}` filters) |

**Pro** (commercial license): `data-animate`, `data-custom-validity`, `data-match-media`, `data-on-raf`, `data-on-resize`, `data-persist`, `data-query-string`, `data-replace-url`, `data-scroll-into-view`, `data-view-transition`. Pro actions: `@clipboard`, `@fit`, `@intl`. Details in `references/attributes.md`.

### Casing rules (common bug source)
- Signal-defining attributes (`bind`, `signals`, `computed`, `ref`, `indicator`): key hyphens -> **camelCase**.
- All others (`class`, `attr`, `on`, `style`): key stays **kebab-case**.
- Use `__case.camel|kebab|snake|pascal` to override, e.g. `data-on:widget-loaded__case.camel`.
- Object-syntax keys with hyphens must be quoted: `{'font-bold': $x}`.

### Common `data-on` modifiers
`__once`, `__prevent`, `__stop`, `__passive`, `__capture`, `__window`, `__document`, `__outside`, `__debounce.500ms[.leading|.notrailing]`, `__throttle.500ms[.noleading|.trailing]`, `__delay.500ms`, `__viewtransition`.

```html
<input data-bind:q data-on:input__debounce.300ms="@get('/search')" />
```

## Backend actions

`@get @post @put @patch @delete @query(url, options?)`. Signals are sent automatically (excluding `_`-prefixed): as `datastar` query param for GET, JSON body otherwise. Header `Datastar-Request: true` is always sent.

Key options: `contentType: 'form'` (send closest form, validates, no signals), `filterSignals: {include, exclude}`, `headers`, `openWhenHidden`, `retry` (`auto|error|always|never`), `requestCancellation` (`auto|cleanup|disabled|AbortController`). By default a new request cancels an in-flight one with same method+URL. Full list in `references/actions-sse.md`.

File uploads: `data-bind` on `<input type=file>` base64-encodes into signals; for real multipart use a `<form enctype="multipart/form-data">` with `contentType: 'form'`.

## SSE responses (the standard way to respond)

Headers: `Content-Type: text/event-stream`, `Cache-Control: no-cache`. Events end with a **blank line**.

```
event: datastar-patch-elements
data: elements <div id="foo">Hello</div>

event: datastar-patch-signals
data: signals {count: 5, old: null}

```

- Default patch = **morph by top-level element ID**. Put IDs on every top-level patched element, and on inner elements whose state you want preserved.
- Other modes via `data: mode` (`outer` default, `inner`, `replace`, `prepend`, `append`, `before`, `after`, `remove`) + `data: selector #id`.
- Run JS by patching a `<script>` into body: `data: mode append`, `data: selector body`, `data: elements <script>...</script>`.
- Prefer an official SDK (Go, etc.) over hand-formatting; SDKs expose `PatchElements`, `PatchSignals`, `ExecuteScript`.

Non-SSE responses also work (`text/html`, `application/json`, `text/javascript`) but SSE is preferred.

## Patterns

**CQRS / live view**
```html
<div id="main" data-init="@get('/updates')">
  <button data-on:click="@post('/do')">Do</button>
</div>
```

**Loading indicator** (non-CQRS)
```html
<button data-indicator:fetching data-attr:disabled="$fetching" data-on:click="@post('/do')">
  Go <span data-show="$fetching">Loading...</span>
</button>
```
Indicator must be declared **before** the `data-init` that fires the request (attributes evaluate in DOM order). With CQRS, instead add a class in the click handler and let the backend patch remove it.

**Active search:** bound input + `__debounce` + `@get`; backend returns patched results container.

**Accessible toggle:** `data-attr:aria-expanded="$_open ? 'true' : 'false'"` with a `_open` local signal.

## Security (always apply)

- **Expressions are evaluated JS.** Never interpolate untrusted user content into `data-*` attribute values; escape with your template engine. Pass user values through signals instead and keep expressions static.
- If unescapable user content must render, wrap it in `data-ignore`.
- Signals are visible and editable client-side: no secrets in signals; always validate on the backend.
- Default mode uses `Function()` so CSP needs `'unsafe-eval'`. **CSP mode**: set `data-nonce="{nonce}"` on `<html>` matching `script-src 'nonce-{nonce}'` (fresh random nonce per full-page response). Trusted Types: allow policy `datastar`. CSP mode does not sanitize expressions.

## Gotchas

- Old syntax `data-on-click` / `data-on-load` is gone; use `data-on:click` / `data-init`.
- `data-computed` must be pure; use `data-effect` for side effects.
- GET requests close SSE when tab hidden unless `openWhenHidden: true` (other methods default true).
- Morph preserves existing attributes unless the patched HTML changes them; data-* attributes re-apply only if changed.
- Don't forget the blank line after each SSE event.
- `<template data-if>` / `data-for` are Rocket-only; plain Datastar has no structural templates (use `data-show` or backend patches).
- Debug with `data-json-signals` and the Datastar Inspector.
