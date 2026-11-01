# Datastar Conventions

- Use Datastar as the primary mechanism for frontend/backend interaction.
- Prefer server-driven updates and keep business logic on the backend where practical.
- Avoid writing custom JavaScript when Datastar or native browser behaviour already solves the problem.
- Keep browser-side dependencies local under `assets/js/`; do not rely on a CDN at runtime.
- Keep Datastar's JavaScript distribution versioned and record where it came from.
- Treat installed Datastar skills, snippets, and remembered APIs as potentially stale.
- When uncertain, verify API names, attributes, event behaviour, and SDK usage against the current official Datastar documentation.
- Do not invent Datastar attributes or assume an old example remains valid.
- Keep signals and server events focused; avoid unnecessary client-side state duplication.
- Handle validation and errors in a way that gives users clear feedback.
