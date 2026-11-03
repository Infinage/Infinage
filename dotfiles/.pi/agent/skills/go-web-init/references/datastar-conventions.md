# Datastar Conventions

Project-specific rules on top of the `datastar` skill. Invoke that skill first for syntax, attributes, actions and SSE format. If it is unavailable, use `https://data-star.dev/reference/`.

## Documentation and Versions

- Prefer official documentation over remembered APIs or snippets.
- Do not use Go SDK docs for browser-side syntax. Use Go SDK docs and `go doc` for server-side APIs.
- Do not inspect bundled or minified JavaScript to discover documented features. Inspect it only for version-specific behaviour, suspected runtime bugs or documentation discrepancies.
- Verify the bundled JavaScript version before using newer features.
- Record the browser bundle and Go SDK versions separately.

## Go SDK

- Use the official SDK: `https://github.com/starfederation/datastar-go`
- Add it only when integration is required:
  `go get github.com/starfederation/datastar-go/datastar`
- Consult `go doc` before guessing SDK API usage.

## HTTP Actions

Match each Datastar action to its server route method (`@get` for safe reads, `@post` to create or trigger, `@put` to replace, `@patch` to partially update, `@delete` to delete). Do not use POST indiscriminately.

## Expressions

- Keep simple event expressions on one line. Put non-trivial ones on multiple lines, one logical statement per line.
- End every statement with a semicolon, including single statements and the last statement.
- Prefer guard clauses and flat conditionals over nested branches or `else if` chains.
- Do not compress complex handlers into one line.
- Move substantial behaviour into external scripts.
- Verify expression-context restrictions against the docs and the installed version. Do not assume ordinary JavaScript works everywhere.
- Semicolon rules apply to Datastar expressions, not `data-signals` declarations or static attribute values.

## Interaction

- Prevent duplicate submissions where necessary.
- Show clear feedback for validation and request failures.
- Preserve user input when requests fail, where practical.

## Browser Assets

- Keep Datastar JavaScript local under `assets/js/`. No CDN at runtime, even if examples show one.
- Record the bundled version and its source.
