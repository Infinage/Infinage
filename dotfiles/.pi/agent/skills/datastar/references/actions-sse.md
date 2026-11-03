# Actions and SSE Events

## Local actions

- `@peek(() => $bar)`: read a signal without subscribing. `data-text="$foo + @peek(() => $bar)"` only re-runs on `$foo`.
- `@setAll(value, {include: RegExp, exclude?: RegExp})`: set all matching signals. `@setAll('', {include: /^form\./})`.
- `@toggleAll({include, exclude?})`: flip booleans. `@toggleAll({include: /^is/})`.

## Backend actions

`@get | @post | @put | @patch | @query | @delete (uri, options?)`

- `@query` sends signals in the body but is safe/idempotent (read-only, like GET without URI size limits).
- Always sends `Datastar-Request: true`. GET: signals in `datastar` query param. Others: JSON body.
- Hidden tab: GET closes the SSE connection and reopens on visible, unless `openWhenHidden: true`.

### Options

| Option | Notes |
|---|---|
| `contentType` | `'json'` (default) or `'form'` (closest form, validated, urlencoded; no signals sent). Multipart if the form has `enctype="multipart/form-data"` |
| `selector` | CSS selector of the form to send with `contentType: 'form'` (default: closest) |
| `filterSignals` | `{include: /.*/, exclude: /(^_\|\._).*/}` defaults |
| `headers` | Extra request headers (e.g. CSRF token) |
| `openWhenHidden` | Default false for GET, true otherwise |
| `payload` | Override fetch payload with a custom object |
| `retry` | `'auto'` (network errors only, default), `'error'` (also 4xx/5xx), `'always'` (all non-204 non-redirect), `'never'` |
| `retryInterval` | ms, default 1000 |
| `retryScaler` | multiplier, default 2 |
| `retryMaxWait` | ms, default 30000 |
| `retryMaxCount` | default 10 |
| `requestCancellation` | `'auto'` (default), `'cleanup'`, `'disabled'`, or an `AbortController` |

```html
<button data-on:click="$ctl = new AbortController(); @get('/x', {requestCancellation: $ctl})">Start</button>
<button data-on:click="$ctl?.abort()">Cancel</button>
```

Cancellation is by method+URL, regardless of which element fired it. Different method or URL runs concurrently.

### Fetch lifecycle events

`datastar-fetch` fires on the element with `evt.detail.type`: `started`, `finished`, `error`, `retrying`, `retries-failed`.
```html
<div data-on:datastar-fetch="evt.detail.type === 'error' && console.log('failed')"></div>
```

## Response content types

| Type | Behavior | Optional headers |
|---|---|---|
| `text/event-stream` | Datastar SSE events (preferred) | none |
| `text/html` | Patch HTML into DOM | `datastar-selector`, `datastar-mode` (outer default, inner, remove, replace, prepend, append, before, after), `datastar-use-view-transition` |
| `application/json` | Merge-patch signals (RFC 7396) | `datastar-only-if-missing: true` |
| `text/javascript` | Execute script | `datastar-script-attributes` (JSON string, e.g. `{"type":"module"}`) |
| 204 | No content, nothing happens | |

## SSE event format

Each event ends with a blank line. Multi-line values repeat the `data:` prefix.

### datastar-patch-elements
```
event: datastar-patch-elements
data: selector #foo
data: mode inner
data: useViewTransition true
data: viewTransitionSelector #main
data: elements <div>
data: elements   Hello
data: elements </div>

```

| Line | Meaning |
|---|---|
| `elements` | HTML to patch (can repeat for multi-line) |
| `selector #foo` | Target; not needed for `outer`/`replace` (matched by ID) |
| `mode` | `outer` (default, morph), `inner`, `replace` (no morph), `prepend`, `append`, `before`, `after`, `remove` |
| `namespace svg` / `mathml` | Patch with that XML namespace (needed for SVG children) |
| `useViewTransition true` | Wrap in View Transition API (default false) |
| `viewTransitionSelector` | Element to transition (default document) |

Remove an element:
```
event: datastar-patch-elements
data: selector #foo
data: mode remove

```

Put IDs on top-level patched elements and on inner elements that hold state (listeners, CSS transitions, focus).

### datastar-patch-signals
```
event: datastar-patch-signals
data: onlyIfMissing true
data: signals {foo: 1, bar: {baz: 2}, gone: null}

```
`signals` is a valid `data-signals` object (JS or JSON). `null` removes a signal. `onlyIfMissing` skips existing signals.

### Executing scripts
Patch a `<script>` into the body (SDKs have `ExecuteScript`):
```
event: datastar-patch-elements
data: mode append
data: selector body
data: elements <script>alert('hi')</script>

```

## Go SDK sketch

```go
sse := datastar.NewSSE(w, r)
sse.PatchElements(`<div id="foo">Hello</div>`)
sse.PatchSignals([]byte(`{count: 5}`))
sse.ExecuteScript(`console.log('hi')`)
```
Other languages have equivalent SDKs; prefer them over manual formatting.

## Compression

SSE streams compress extremely well (200:1 with Brotli is common), which makes fat-morph cheap. Enable it at the server/proxy.
