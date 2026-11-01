# Go Conventions

- Follow modern, idiomatic Go practices and the conventions already present in the repository.
- Prefer the standard library. Ask before adding dependencies.
- Organise code around cohesive responsibilities, not arbitrary file-size limits.
- Keep functions focused and straightforward to test.
- Avoid unnecessary interfaces, generics, factories, and abstraction layers.
- Define interfaces at useful boundaries rather than anticipating hypothetical implementations.
- Keep HTTP handlers thin: parse and validate transport input, call application behaviour, and produce an HTTP response.
- Keep business rules independent of HTTP details where practical.
- Keep persistence concerns in a clear data-access boundary when the application warrants one.
- Pass `context.Context` to operations that need cancellation, deadlines, or request-scoped values.
- Handle errors explicitly and add useful context when returning them.
- Avoid global mutable state.
- Use `gofmt`; run `go test ./...` after meaningful changes.
- Add focused tests for behaviour, edge cases, and regressions.
- Do not create packages merely to make the directory tree look architectural.
