# Datastar Attribute Details

Modifiers use `__name` and tags use `.tag`, e.g. `data-on:click__window__debounce.500ms.leading`.
`__case` (everywhere it applies): `.camel | .kebab | .snake | .pascal`. Default is camel for signal-defining attributes, kebab for the rest.

## Core

**data-bind**: Creates the signal if missing; initial signal value comes from the element unless the signal is predefined. Predefined type is preserved (`data-signals:n="0"` + `<select>` -> number). Predefine as `[]` to collect multiple checkboxes. Files: `{name, contents, mime}[]` (base64). Modifiers: `__prop.checked` (bind a specific property), `__event.input.change` (events that sync back). Custom elements default to `value`/`change`.
```html
<my-toggle data-bind:is-checked__prop.checked__event.change></my-toggle>
```

**data-attr**: single `data-attr:aria-label="$foo"` or object `data-attr="{'aria-label': $foo, disabled: $bar}"`.

**data-class**: `data-class:font-bold="$x == 'strong'"` or object form.

**data-computed**: `data-computed:foo="$a + $b"`; object form takes arrow fns: `data-computed="{foo: () => $a + $b}"`.

**data-effect**: runs on load and whenever signals read in it change.

**data-ignore** (`__self`), **data-ignore-morph** (remove by patching element without it).

**data-indicator**: `data-indicator:fetching` or `data-indicator="fetching"`.

**data-init**: modifiers `__delay.500ms`, `__viewtransition`. Runs on load, when patched in, or when attribute value changes.

**data-json-signals**: `data-json-signals="{include: /user/, exclude: /password/}"`, `__terse` for compact.

**data-on**: `evt` available. `data-on:submit` auto-prevents default. Modifiers: `__once __passive __capture` (built-in events only), `__case`, `__delay`, `__debounce`, `__throttle`, `__viewtransition`, `__window`, `__document`, `__outside`, `__prevent`, `__stop`.

**data-on-intersect**: `__once __exit __half __full __threshold.25 __delay __debounce __throttle __viewtransition`.

**data-on-interval**: default 1s. `__duration.500ms` (add `.leading` to fire immediately), `__viewtransition`.

**data-on-signal-patch**: `patch` variable holds details. Modifiers `__delay __debounce __throttle`. Filter with companion attribute:
```html
<div data-on-signal-patch="console.log(patch)"
     data-on-signal-patch-filter="{include: /^counter$/, exclude: /temp$/}"></div>
```

**data-preserve-attr**: space-separated list, keeps attrs across morphs (e.g. `<details open data-preserve-attr="open">`).

**data-ref**: `data-ref:foo` -> `$foo` is the element (`$foo.tagName`).

**data-show**: boolean expression; pair with inline `display:none`.

**data-signals**: dot-nesting `data-signals:form.baz="2"`; object form accepts JS or JSON; `null/undefined` removes; `__ifmissing` only sets absent keys. `_` prefix = not sent to backend (change via `filterSignals`). Later (deeper) definitions override earlier.

**data-style**: `data-style:display="$hiding && 'none'"` or object form. Falsy/empty restores the original inline value, or removes the property.

**data-text**: text content from expression.

## Pro attributes

- **data-animate**: animate element attributes over time, reactive to signals in the expression.
- **data-custom-validity**: expression returns message string; empty = valid.
  `data-custom-validity="$foo === $bar ? '' : 'Values must match.'"`
- **data-match-media**: `data-match-media:is-dark="'prefers-color-scheme: dark'"` sets a boolean signal. Complex queries need explicit parentheses.
- **data-on-raf**: every animation frame; `__throttle`.
- **data-on-resize**: element size changes; `__debounce`, `__throttle`.
- **data-persist**: persist signals to localStorage (key `datastar`). Filter `data-persist="{include: /foo/}"`, custom key `data-persist:mykey`, `__session` for sessionStorage.
- **data-query-string**: sync signals <-> URL query. Filter object; `__filter` drops empty values; `__history` adds history entries and restores on popstate.
- **data-replace-url**: `data-replace-url="`/page${page}`"` (evaluated expression, no reload).
- **data-scroll-into-view**: `__smooth __instant __auto`, `__hstart|hcenter|hend|hnearest`, `__vstart|vcenter|vend|vnearest`, `__focus`.
- **data-view-transition**: sets `view-transition-name` explicitly.

## Evaluation order and errors

- DOM is walked depth-first; attributes apply in written order (matters for `data-indicator` before `data-init`).
- Attributes apply on load and re-apply after patches that add/remove/change them.
- Runtime errors log `datastar runtime error: <code>` with a "More info" URL to a context-aware explanation page.
