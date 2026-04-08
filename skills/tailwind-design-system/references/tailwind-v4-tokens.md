# Tailwind v4 Token Namespaces

## CSS Variable Namespaces

Tailwind v4 uses `@theme inline` in globals.css instead of tailwind.config.js. Each utility type has a specific CSS variable namespace:

| Utility | Namespace | Example |
|---------|-----------|---------|
| Colors | `--color-*` | `--color-brand: var(--color-blue-600)` → `text-brand`, `bg-brand` |
| Font size | `--text-*` | `--text-hero01: 3.75rem` → `text-hero01` |
| Font family | `--font-*` | `--font-sans: ...` → `font-sans` |
| Spacing | `--spacing-*` | Generally not needed; use Tailwind defaults |
| Shadows | `--shadow-*` | `--shadow-card: ...` → `shadow-card` |

**Common mistake:** Using `--font-size-*` for font sizes. This creates the CSS variable but does NOT generate the `text-*` utility class. Always use `--text-*`.

## Verifying Namespaces

Check `node_modules/tailwindcss/theme.css` for the authoritative list:

```bash
grep "^  --text-" node_modules/tailwindcss/theme.css    # font sizes
grep "^  --color-" node_modules/tailwindcss/theme.css   # colors
```

## Referencing Tailwind Defaults

Within `@theme inline`, you can reference Tailwind's built-in values:

```css
@theme inline {
  --color-brand: var(--color-blue-600);         /* works — references Tailwind's blue-600 */
  --text-hero01: var(--text-6xl);               /* may NOT work — self-referencing within @theme */
  --text-hero01: 3.75rem;                       /* works — use raw values for font sizes */
}
```

Color references via `var()` work because Tailwind resolves them at build time. Font size references are less reliable — prefer raw values.

## tailwind-merge Custom Classes

When custom tokens use the `text-*` prefix for both colors and font sizes, tailwind-merge can't distinguish them. Configure explicitly:

```ts
import { extendTailwindMerge } from 'tailwind-merge'

const twMerge = extendTailwindMerge({
  extend: {
    classGroups: {
      'font-size': [
        'text-hero01', 'text-hero02',
        'text-heading01', 'text-heading02', 'text-heading03',
        'text-body01',
        'text-caption01', 'text-caption02',
      ],
    },
  },
})
```

Without this, `cn('text-brand', 'text-hero01')` may incorrectly drop one class because tailwind-merge sees both as `text-*` conflicts.

## Arbitrary Values to Avoid

Tailwind v4 supports more utility values natively than v3:

| Arbitrary (avoid) | Native (prefer) |
|---|---|
| `z-[60]` | `z-60` |
| `z-[5]` | `z-5` |
| `aspect-[9/16]` | `aspect-9/16` |
| `rounded-t-[2rem]` | `rounded-t-4xl` |
| `h-[100vh]` | `h-screen` |
