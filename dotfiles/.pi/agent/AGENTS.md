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

- Count every failed or unproductive action on the same problem as an attempt.
- Treat failures with the same underlying cause as the same problem, regardless of tool, error, parameters, or approach.
- Output that does not achieve the goal is a failure, even if it looks like progress.
- After **three attempts**, stop and report. Do not keep trying autonomously.
- Wait/poll loops must have a fixed retry or time limit set before starting. Each repeated failure counts as an attempt; do not use a loop to bypass the attempt limit.
- Report in **6 lines or fewer**: what works, what failed, and what decision/input you need from the user (with 2-3 options).
- Challenge pages, CAPTCHAs, and paywalls get **one genuine attempt**, then stop and report with a workaround. Rate limits and auth errors get one retry.
- Do not silently change approaches. State the new approach before trying it.
- Reset the count only when the user provides new information or the underlying cause materially changes.
- Summarise tool output in **5 lines or fewer**. For large output, write it to a file instead.

## Documentation

- Keep documentation aligned with actual behaviour.
- Document setup, configuration, externally observable behaviour and important decisions.
- Do not invent requirements or claim unsupported capabilities.
