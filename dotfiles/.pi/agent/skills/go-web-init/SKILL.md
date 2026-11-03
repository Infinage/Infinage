---
name: go-web-init
description: "Initialise, build and maintain Go web applications using the user's preferred lightweight stack: Go, Datastar, Tailwind CSS, local browser assets, html/template, Make and Air. Use whenever the user wants to scaffold, start, extend or fix a Go web app or web UI, mentions Datastar with Go, Tailwind with html/template, or asks for a small server-rendered Go project, even if they don't name this skill."
---

# Go Web Projects

Create and maintain small, conventional Go web applications using the user's preferred setup. Inspect the target directory first. Do not overwrite existing files without approval.

## Conventions (read before implementing)

- Go code: `references/go-conventions.md`
- HTML templates and Tailwind: `references/html-tailwind-conventions.md`
- Datastar: invoke the `datastar` skill first, when available, then read `references/datastar-conventions.md`. Project rules here override the skill's generic guidance (for example, the skill's CDN script tag).

General engineering rules (dependencies, testing, planning) come from the project's AGENTS.md and are not repeated here.

## Before Creating Files

Clarify only what is needed:

- Project name and module path.
- Web application or service with a web UI.
- Required Go version and database needs.
- Whether authentication or other infrastructure is required now.

Do not add infrastructure or features speculatively.

## Preferred Layout

Use this as a starting point, not mandatory architecture:

```text
project/
├── assets/
│   ├── css/
│   │   ├── input.css
│   │   └── index.css
│   ├── html/
│   │   └── index.html
│   └── js/
│       └── datastar.js
├── go.mod
├── main.go
├── Makefile
└── .air.toml
```

- Keep browser-facing assets, including HTML templates, under `assets/`.
- Keep templates in separate files under `assets/html/`.
- Use Go's html/template for HTML rendering.
- Add directories and packages only when responsibilities justify them.
- Ensure the application serves the local assets correctly.

## Browser-Side Dependencies

- Obtain the bundle from Datastar's official distribution and save it as `assets/js/datastar.js`.
- Serve it locally. No CDN at runtime.
- Record the bundle version and source. Do not invent versions or reuse stale copies.

## Tailwind CSS Setup

Use the Tailwind CSS CLI workflow.

Create `assets/css/input.css`:

```css
@import "tailwindcss";
```

Create `Makefile`:

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

Create `tailwind.config.js` (needed for user's neovim autocompletion):

```javaScript
module.exports = {
  content: ["./assets/html/**/*.html"],
};
```

- `tailwindcss` and `air` are development tools installed separately. Check the installed Tailwind CLI version and confirm it is v4.
- `assets/css/index.css` is a build output. Whether to commit it depends on the deployment workflow; ask if uncertain.

## Completion Checklist

1. Verify the Go module and entry point.
2. Verify local Datastar assets are present and served.
3. Verify the Tailwind CLI generates CSS.
4. Verify `air` builds and runs the application.
5. Run `djlint` on modified templates (see the HTML reference).
6. Run `go fmt` and `go test ./...`.
7. Explain required tools, generated files and startup steps.

Do not claim setup works unless the relevant checks ran.
