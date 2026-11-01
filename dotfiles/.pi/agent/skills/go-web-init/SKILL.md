---
name: go-web-init
description: "Initialise a Go web application using the user's preferred lightweight stack: Go, Datastar, Tailwind CSS, local browser assets, html/template, Make, and Air. Use when starting or scaffolding a new Go web project."
---

# Initialise a Go web project

Create a small, conventional Go web application using the user's preferred setup. First inspect the target directory and ask about any important missing project details. Do not overwrite existing files without approval.

## Before creating files

Clarify only what is needed to initialise the project:

- Project name and module path.
- Whether this is a web application or a service with a web UI.
- The required Go version and whether a database is needed.
- Whether the project needs authentication or other infrastructure now.

Do not add a database, authentication, frontend framework, or other feature speculatively.

## Preferred layout

Use this as a starting point, not a mandatory architecture:

```text
project/
├── assets/
│   ├── css/
│   │   ├── input.css
│   │   └── index.css
│   └── js/
│       └── datastar.js
├── templates/
│   └── ...
├── go.mod
├── main.go
├── Makefile
└── .air.toml
```

Add directories and packages only when responsibilities justify them. Keep HTML templates in separate files under `templates/`. Use Go's `html/template` for HTML rendering.

## Browser-side dependencies

- Download browser-side JavaScript dependencies and keep local copies under `assets/js/`.
- Do not rely on a CDN at runtime.
- For Datastar, obtain the appropriate `datastar.js` distribution from the official Datastar release/CDN source and save it as `assets/js/datastar.js`.
- Record the version and source used. Do not silently use an old cached copy or invent a version.
- Do not add other JavaScript libraries unless the user approves them.
- Ensure the application serves the local assets correctly.

## Tailwind CSS setup

Use the Tailwind CSS CLI workflow already preferred by the user.

Create `assets/css/input.css`:

```css
@import "tailwindcss";
```

Create a `Makefile` with the following development targets, adjusting only when the project needs it:

```makefile
dev:
	@$(MAKE) -j2 watch-css watch-go

watch-css:
	tailwindcss -i assets/css/input.css -o assets/css/index.css --watch

watch-go:
	air

.PHONY: dev watch-css watch-go
```

Create `.air.toml`:

```toml
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/main ."
  bin = "./tmp/main"
  include_ext = ["go", "html"]
  exclude_dir = ["tmp"]
  delay = 200

[log]
  time = false
```

The `tailwindcss` CLI and `air` are development tools that must be installed separately. Do not add an npm-based frontend toolchain unless explicitly approved. Check the installed Tailwind CLI version and ensure the chosen configuration is compatible.

The generated `assets/css/index.css` is a build output. Decide whether it belongs in version control based on the project's deployment and build workflow; ask if uncertain.

## HTML and templates

- Prefer semantic HTML elements over generic containers when an appropriate element exists.
- Use native browser behaviour and built-in form validation before writing custom JavaScript.
- Build pages from small, reusable template fragments where that improves clarity.
- Keep templates readable; avoid deeply nested conditionals and duplicated markup.
- Follow `references/html-tailwind-conventions.md`.

## Datastar

- Prefer Datastar's server-driven interaction model.
- Keep application and business logic on the backend where practical.
- Use client-side JavaScript only when browser APIs or interaction requirements genuinely need it.
- Follow `references/datastar-conventions.md`.
- Verify APIs against current official Datastar documentation when uncertain. Installed skills or examples may be stale.

## Go

- Follow `references/go-conventions.md`.
- Use the standard library and existing dependencies by default.
- Do not add dependencies without approval.
- Keep handlers focused on HTTP concerns and avoid placing the entire application in one large handler file.

## Completion checklist

After scaffolding:

1. Verify the Go module and entry point.
2. Verify local Datastar assets are present and served.
3. Verify Tailwind CLI can generate the CSS.
4. Verify `air` can build and run the application.
5. Run `gofmt` and `go test ./...`.
6. Explain required local tools, generated files, and how to start development.

Do not claim the setup works unless the relevant checks have been run.
