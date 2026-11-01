# HTML and Tailwind Conventions

## HTML

- Use Go's `html/template` and keep templates in separate files under `templates/`.
- Build pages from small template fragments where that improves reuse and readability.
- Prefer native semantic HTML elements over generic `div` and `span` elements when an appropriate element exists.
- Use elements according to their actual semantics. Do not use an element merely because its name sounds convenient.
- Prefer native browser capabilities: form submission, input types, `required`, `min`, `max`, `pattern`, labels, buttons, and built-in validation.
- Use JavaScript only when native HTML and Datastar cannot reasonably provide the required behaviour.
- Keep markup accessible: labels for controls, sensible heading order, keyboard-operable interactions, and meaningful button text.

## Formatting

The preferred HTML indentation is **two spaces**.

For elements with multiple attributes:
- Keep short elements on one line when readable.
- Put the opening tag's attributes on separate lines when the tag becomes long.
- Indent continuation lines by two additional spaces relative to the element.
- Put the closing `>` on its own line when using the multiline style.
- Keep the closing tag aligned with the opening tag.

Preferred example:

```html
  <div data-show="$_contact.showpopup"
    class="flex flex-col fixed bottom-6 left-6 right-6 border rounded-md overflow-hidden
      border-gray-400/50 shadow-gray-400 sm:left-auto sm:w-[25rem]"
  >
    ...
  </div>
```

This is a project formatting preference, not a claim that the style has a universally accepted formal name. Apply it consistently within a project.

## Tailwind CSS

- Use Tailwind utility classes for styling.
- Keep `assets/css/input.css` as the Tailwind entry point, using `@import "tailwindcss";` for the preferred Tailwind v4 setup.
- Generate `assets/css/index.css` with the Tailwind CLI.
- Do not add a JavaScript package manager or frontend build framework unless approved.
- Avoid unnecessary custom CSS when utilities are sufficient.
- Use responsive utilities deliberately; check layouts at mobile and desktop widths.
- Keep class lists readable. Break long class attributes across lines using the formatting convention above.
- Do not invent a component system or abstraction for markup that is only used once.
