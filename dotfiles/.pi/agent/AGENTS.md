# Engineering Principles

These guidelines apply to all projects unless a project-specific instruction explicitly overrides them.

## General approach

- Prefer simple, readable, maintainable solutions over clever or unnecessarily abstract ones.
- Keep the implementation as small as reasonably possible.
- Understand the existing codebase and conventions before making changes.
- Implement only what was requested. Avoid unrelated refactoring and speculative features.
- Prefer explicit, predictable behaviour over hidden magic.
- Do not optimise prematurely.
- Preserve existing behaviour unless a change is explicitly required.

## Clarification and decisions

- Ask questions when requirements are ambiguous and different interpretations could materially change the result.
- Do not make significant product, architectural, security, data-model, or dependency decisions without approval.
- For minor details, use sensible defaults and state important assumptions.
- Before substantial work, identify relevant edge cases and propose a concise plan.
- If a requested approach has meaningful drawbacks, explain them and offer alternatives.
- Do not repeatedly interrupt work for trivial decisions.

## Code quality

- Follow the language's modern, idiomatic best practices.
- Prefer cohesive, focused functions and modules with clear responsibilities.
- Use abstractions only when they solve a real problem.
- Avoid unnecessary interfaces, wrappers, layers, configuration, and indirection.
- Choose clear names and straightforward control flow.
- Handle errors deliberately. Do not silently ignore unexpected failures.
- Keep comments concise. Explain non-obvious reasoning and constraints; do not merely narrate the code.
- Do not add comments that are redundant with clear code.

## Dependencies and tools

- Prefer existing project dependencies and standard tools.
- Do not introduce a dependency, framework, build tool, or service without approval.
- When proposing one, explain the problem it solves, alternatives considered, and its maintenance or operational cost.
- Prefer vendoring or locally hosting browser-side dependencies when that is the established project convention.
- Do not silently change dependency versions or introduce remote runtime dependencies.

## Testing and verification

- Add or update tests for meaningful behaviour whenever practical.
- Add regression tests for bug fixes.
- Cover important edge cases and error paths.
- Keep tests deterministic and avoid unnecessary mocking.
- Run relevant tests, formatters, linters, and build checks after changes.
- Never claim a check passed unless it was actually run.
- If a check cannot be run, state that clearly.

## Workflow

For substantial changes:

1. Inspect the relevant code and documentation.
2. Clarify requirements and material ambiguities.
3. Propose a concise implementation plan.
4. Identify affected areas, risks, and tests.
5. Implement incrementally.
6. Run relevant verification.
7. Review the diff for correctness, scope, and unnecessary complexity.
8. Summarise changes, decisions, checks performed, and outstanding concerns.

For small, straightforward changes, work directly without unnecessary ceremony.

## Documentation

- Keep documentation aligned with actual behaviour.
- Document setup, configuration, externally observable behaviour, and non-obvious decisions.
- Do not invent product requirements or claim unsupported capabilities.
