# Engineering Principles

These guidelines apply to all projects unless project-specific instructions explicitly override them.

## General Approach

- Prefer simple, readable, maintainable solutions over clever or unnecessarily abstract ones.
- Keep implementations small and focused.
- Understand the existing codebase and conventions before making changes.
- Implement only what was requested. Avoid unrelated refactoring and speculative features.
- Prefer explicit, predictable behaviour. Preserve existing behaviour unless a change is required.
- Do not optimise prematurely.

## Clarification and Decisions

- Ask when ambiguity could materially affect implementation.
- Do not make significant product, architectural, security, data-model or dependency decisions without approval.
- Use sensible defaults for minor details and state important assumptions.
- Explain meaningful trade-offs and alternatives.
- Avoid unnecessary interruptions over trivial decisions.

## Code Quality

- Follow modern, idiomatic language conventions.
- Prefer cohesive functions and modules with clear responsibilities.
- Avoid unnecessary abstractions, interfaces, wrappers and indirection.
- Use clear names and straightforward control flow.
- Prefer guard clauses and early exits over deeply nested conditionals where supported.
- Handle errors deliberately.
- Keep comments concise and focused on non-obvious reasoning. Do not narrate implementation history or obvious behaviour.

## Dependencies and Tools

- Prefer existing dependencies and standard tools.
- Do not introduce dependencies, frameworks, services or build tools without approval.
- Explain benefits and maintenance costs when proposing dependencies.
- Follow established project conventions for browser-side dependencies.
- Do not silently change dependency versions or introduce remote runtime dependencies.

## Testing and Verification

- Add or update tests for meaningful behaviour and bug fixes.
- Tests should primarily verify expected behaviour and invariants.
- Avoid coupling tests to implementation details unless those details are themselves under test.
- Cover important edge cases.
- Keep tests deterministic.
- Run relevant tests, formatters, linters, and build checks after changes.
- Never claim checks passed unless they were actually run.
- Report anything that could not be verified.

## Workflow

- Inspect relevant code, specifications and documentation before making changes.
- Read the relevant project conventions and invoke applicable skills before implementation.
- Read only the documentation relevant to the current task. Follow references from specifications instead of reading every implementation record.
- For substantial work, clarify requirements and propose a concise implementation plan before coding.
- Break substantial tasks into small, independently verifiable increments.
- Prefer complete, working slices of functionality over large batches of changes.
- Implement one coherent increment at a time. Keep the application working and testable.
- Verify each increment and review the diff before proceeding.
- Follow the approved plan without repeatedly asking permission for routine steps.
- Seek approval for significant scope changes or new architectural decisions.
- For small, straightforward changes, work directly without unnecessary planning.
- Summarise changes, tests performed, and outstanding concerns.
- For Go web applications using Go, Datastar and Tailwind CSS, new or existing, invoke the `go-web-init` skill and read its relevant convention references before implementation. It will direct you to the `datastar` skill for Datastar work.

## When Stuck

- Any failed or unproductive action on the same problem counts as an attempt (code change, fixture rebuild, changed verification, retried tool call).
- After **three attempts on the same problem**, stop. Do not try another approach autonomously.
- Report in 6 lines or fewer:
  1. What is working.
  2. What was attempted and why it failed.
  3. The specific decision or information needed from the user, with 2-3 options.
- Do not silently change approaches. State the new approach before trying it.
- If external verification fails twice, stop and give a short manual-verification checklist instead.
- Attempt counting resets only with new information from the user or verification, or when the underlying problem materially changes; changing the implementation approach does not reset the count.
- Summarise tool output in 5 lines or fewer. For large output, write it to a file and reference the path instead of pasting.

## Documentation

- Keep documentation aligned with actual behaviour.
- Document setup, configuration, externally observable behaviour and important decisions.
- Do not invent requirements or claim unsupported capabilities.
