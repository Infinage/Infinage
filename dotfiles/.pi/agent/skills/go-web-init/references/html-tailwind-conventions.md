# HTML and Tailwind Conventions

## HTML

- Use Go's `html/template`; keep templates under `assets/html/`.
- Prefer semantic HTML and native browser capabilities. Use built-in form validation before custom JavaScript.
- Keep markup accessible. Use JavaScript only when native HTML and Datastar cannot provide the behaviour.
- Build pages from small, reusable template fragments where that improves clarity. Avoid deeply nested conditionals and duplicated markup.
- Use two spaces for indentation.
- Keep source lines within 80 characters.
- Put every HTML attribute on its own line, indented two spaces beyond the opening tag.
- Align closing tags with their opening tags.
- Put the closing `>` on its own line.
- Break long attribute values across lines, indenting continuation lines to match Go-style formatting.
- Format Go template control structures on separate lines.

## Preferred Formatting

One attribute per line, even for short attributes. Keep simple values on one line. Break long class lists and other long values across lines.

```html
<section
  id="main"
  class="space-y-4"
>
  <tr
    class="bg-gray-100 dark:bg-gray-900/50 border-y border-gray-200
      dark:border-gray-800"
  >
    ...
  </tr>
</section>
```

The same formatting applies to SVG elements and their attributes:

```html
<svg
  class="w-6 h-6 shrink-0 group-hover:text-blue-600
    dark:group-hover:text-blue-400 transition"
  data-class="view === 'dictionary' ? 'text-blue-500' : ''"
  fill="none"
  stroke="currentColor"
  viewBox="0 0 24 24"
>
  <path
    stroke-linecap="round"
    stroke-linejoin="round"
    stroke-width="2"
    d="M12 6.253v13m0-13C10.832 5.477 9.246 5
      7.5 5S4.168 5.477 3 6.253v13C4.168 18.477
      5.754 18 7.5 18s3.332.477 4.5 1.253"
  >
  </path>
</svg>
```

## Tailwind CSS (v4)

- Use Tailwind utility classes for styling. Prefer utilities over custom CSS.
- Entry point is `assets/css/input.css`:

  ```css
  @import "tailwindcss";
  ```

- Generate `assets/css/index.css` with the Tailwind CLI.
- Prefer utilities over unnecessary custom CSS.
- Use responsive utilities and check mobile and desktop layouts.
- Keep class lists readable; break long values across lines.
- Do not create abstractions for markup used only once.

## Formatting Check

After modifying templates, run:

```bash
djlint assets/html/app.html --reformat --configuration ~/.djlintrc
```

Replace the filename with the actual modified template paths. Review the output and ensure Go template syntax and preferred formatting are preserved.
