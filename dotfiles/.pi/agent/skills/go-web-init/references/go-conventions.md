# Go Conventions

General principles (simplicity, dependencies, testing, error handling) live in AGENTS.md. This file covers Go-specific rules.

- Follow modern, idiomatic Go and existing repository conventions.
- Prefer the standard library. Ask before adding dependencies.
- Keep source-code lines within 80 characters. Break long expressions, declarations and comments across lines.
- Organise code around cohesive responsibilities, not arbitrary file-size limits.
- Keep functions focused and straightforward to test.
- Avoid unnecessary interfaces, generics, factories and abstraction layers.
- Define interfaces at useful boundaries rather than anticipating hypothetical implementations.
- Keep HTTP handlers thin: parse and validate transport input, call application behaviour, and produce a response.
- Keep route registration explicit and easy to trace.
- Keep business rules independent of HTTP details where practical.
- Keep persistence in a clear data-access boundary when the application warrants one.
- Pass `context.Context` to operations that need cancellation, deadlines or request-scoped values.
- Add useful context when returning errors.
- Avoid global mutable state.
- For one-off HTML template data, prefer `map[string]any` over custom structs.
- Write brief comments for all functions and methods, exported or not. Explain purpose, not implementation.
- Run `go fmt`, then `go test ./...` after meaningful changes.
- Do not create packages merely to make the directory tree look architectural.
