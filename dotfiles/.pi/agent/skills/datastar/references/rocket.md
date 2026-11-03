# Rocket (beta: API may change)

Datastar's web component API. Load `datastar-rocket.js` **instead of** `datastar.js` (it bundles both). Use for complex frontend logic, third-party widgets, or anything too heavy for data-* expressions. Principle: props down, events up.

```js
import { rocket } from '/path/datastar-rocket.js'

rocket('demo-counter', {            // tag must contain a hyphen, must be unique
  mode: 'light',                    // 'light' | 'open' (default) | 'closed'
  props: ({ number, string }) => ({
    count: number.step(1).min(0),
    label: string.trim.default('Counter'),
  }),
  setup: ({ $$, observeProps, props, cleanup }) => {   // once per instance, before first render
    $$.count = props.count
    observeProps(() => { $$.count = props.count }, 'count')
  },
  render: ({ html, props: { count, label } }) => html`
    <button data-on:click="$$count += 1" data-text="${label} + ': ' + $$count"></button>
    <template data-if="$$count !== ${count}">
      <button data-on:click="$$count = ${count}">Reset</button>
    </template>`,
})
```
```html
<demo-counter count="5" label="Inventory"></demo-counter>
```

## Definition fields

| Field | Purpose |
|---|---|
| `mode` | Light DOM (inherits page CSS), open shadow (encapsulated, debuggable), closed shadow. Theme shadow components via CSS custom properties |
| `props` | `(codecs) => defs`. Public API: observed attributes, decoding, defaults, host property accessors |
| `setup` | Local signals, computed, observers, timers, cleanup. No refs available yet |
| `onFirstRender` | Runs once after first render; gets setup context plus `refs` (from `data-ref:name`). For DOM measuring, focus, third-party widget init |
| `render` | Returns `html`/`svg` template (or text, nodes, iterables, null). Re-runs often, so keep it declarative |
| `renderOnPropChange` | `false`, or `({host, props, changes}) => boolean`. Default true; renders coalesce per turn |
| `manifest` | `{slots: [{name, description}], events: [{name, kind, bubbles, composed, description}]}` for tooling. `publishRocketManifests({endpoint})`; `Class.manifest()` per component |

## Props and codecs

Codecs are immutable fluent builders; invalid input degrades to a sensible zero value rather than throwing (a throwing `decode` warns and falls back to default). Prop `startDate` <-> attribute `start-date`. Property writes encode back to attributes.

| Codec | Zero value | Members |
|---|---|---|
| `string` | `""` | `.trim .upper .lower .kebab .camel .snake .pascal .title .prefix(v) .suffix(v) .maxLength(n) .default(v)` |
| `number` | `0` | `.min .max .clamp(min,max) .step(step,base?) .round .ceil(d?) .floor(d?) .fit(inMin,inMax,outMin,outMax,clamp?,round?) .default` |
| `bool` | `false` | `.default`. `<x open>` is true |
| `date` | fresh Date | `.default(() => new Date())` |
| `json` | `{}` | `.default(() => [])` (use factories for objects) |
| `js` | `{}` | JS-literal syntax (unquoted keys) |
| `bin` | empty `Uint8Array` | base64 in attribute |
| `array(codec)` / `array(a, b, c)` | `[]` / tuple | list vs fixed-position tuple |
| `object({...})` | per-field defaults | nested typed object |
| `oneOf('a','b')` or `oneOf(codecA, codecB)` | first entry | enums/unions, `.default` |

Custom: `createCodec({decode(value: unknown), encode(value)})`; wrap existing codecs when possible.

## Setup context

| Helper | Use |
|---|---|
| `props` | Decoded props (not reactive; use `observeProps`) |
| `$$` | Instance-local signals: `$$.count = 0` creates `$$count`. Assign a function for computed: `$$.label = () => $$.count + 1` |
| `$` | Global Datastar signal store |
| `actions` | Global actions, e.g. `actions.intl(...)` |
| `action(name, fn)` | Local action callable as `@name()` in markup (`dispatchRocket` is reserved) |
| `effect(fn)` | Reactive side effect with cleanup tracking |
| `cleanup(fn)` | Run on disconnect (timers, observers) |
| `observeProps(fn, ...names)` | `fn(props, changes)`; omit names to watch all |
| `apply(root, merge?)` | Activate Datastar on injected DOM |
| `render(overrides, ...args)` | Force coarse re-render with up to 8 extra args to `render` (async/error branches only; use signals for high-frequency state) |
| `overrideProp(name, getter?, setter?)` | Wrap a prop's host accessor (`(getDefault)=>...`, `(v, setDefault)=>...`). Ref-dependent ones go in `onFirstRender` |
| `defineHostProp(name, descriptor)` | Non-prop host members (methods, read-only props) |
| `host` | The custom element |

**Props vs signals:** if a page author should set it on the element, it's a prop; if it's internal UI state or coordinates external calls, it's a `$$` signal.

## Render features

- Interpolating in attributes: `false/null/undefined` omit the attribute; `true` yields empty boolean attribute. In content, booleans/null/undefined render nothing (pass a string for literal "true").
- Nest fragments and arrays: `${items.map(i => html`<li>${i.label}</li>`)}`.
- `svg` helper: `${svg`<svg>...</svg>`}`.
- Light DOM `<slot>` is a Rocket projection marker (default and named; fallback content supported). Shadow DOM uses native slots.
- **Structural templates** (Rocket only):
  - `<template data-if="expr">`, `data-else-if`, `data-else`: only the active branch is mounted. Use `data-show` to keep mounted.
  - `<template data-for="letter, row in $$letters">`: forms `"$$xs"` (item, i), `"x in $$xs"`, `"x, idx in $$xs"`. Iterates any iterable expression. Rows keyed by position (no identity preserved on reorder). No index-only form.

## Scope rewriting and `__root`

`$$name` in rendered expressions is rewritten to `_rocket.<tag>.<instanceId>.name`, where instanceId is the host `id` (normalized) or a sequential fallback. Give instances ids for stable paths. Write `$$count`, never the rewritten path.

`__root` keeps a signal-name attribute at page scope for authored host children inside shadow-mode components: `data-bind:name__root`, `data-computed:x__root`, `data-indicator:x__root`, `data-ref:x__root`. Use sparingly (wrapper components only).

## Patterns

- Async load in `setup`: fetch, then `render({}, user, null)`; `cleanup(() => cancelled = true)`.
- Imperative libs (charts): `renderOnPropChange: false` or filter by `changes`, update inside `observeProps`.
- Form wrappers: `overrideProp('value', ...)` in `onFirstRender` reading from `refs.input`.
- Biome may flag `${...}` in expression strings (`noTemplateCurlyInString`); disable for Rocket sources.
