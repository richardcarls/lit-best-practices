---
id: 3-5
title: CSS System Colors for Forced Colors Mode
category: Styling
priority: HIGH
tags: [css, styling, accessibility, forced-colors, system-colors, web-components]
description: Use CSS System Colors as component defaults so forced-colors mode remains visible and usable
---

## Problem

Hard-coded color values (`#fff`, `rgba(0, 0, 0, 0.1)`, `currentColor`) are replaced by
forced-colors mode with system colors. Components using hard-coded colors can become
invisible or lose their visual structure in Windows High Contrast mode and other contrast
themes.

## CSS System Color Tokens

Use these semantic CSS System Colors wherever the meaning matches:

| System Color | Use For |
| --- | --- |
| `Canvas` | Page or component background |
| `CanvasText` | Default text on `Canvas` |
| `ButtonFace` | Button or control background |
| `ButtonText` | Text on `ButtonFace` |
| `ButtonBorder` | Button border |
| `Highlight` | Selected item background |
| `HighlightText` | Text on `Highlight` |
| `LinkText` | Hyperlink text |
| `GrayText` | Disabled text |
| `Field` | Input field background |
| `FieldText` | Text in input fields |

## Correct

```css
my-button::part(base) {
  background-color: ButtonFace;
  color: ButtonText;
  border: 1px solid ButtonBorder;
}

my-button::part(base):focus-visible {
  outline: 2px solid Highlight;
}

my-button[disabled]::part(base) {
  color: GrayText;
  border-color: GrayText;
}
```

Use CSS custom properties with System Color fallbacks so component theming works in all modes:

```css
:host {
  --component-surface: Canvas;
  --component-on-surface: CanvasText;
  --component-border: ButtonBorder;
  --component-selected: Highlight;
  --component-selected-text: HighlightText;
}

.container {
  background: var(--component-surface);
  color: var(--component-on-surface);
  border: 1px solid var(--component-border);
}
```

Consumers can override the custom properties for brand theming. The System Color defaults keep
the component accessible in forced-colors mode without a separate override stylesheet.

## Incorrect

```css
my-button::part(base) {
  background-color: #f0f0f0;
  color: #333;
  border: 1px solid rgba(0, 0, 0, 0.2);
}
```

## Do Not Do

- Use `rgba()` opacity for borders or overlays that must remain visible in forced-colors mode.
- Use `currentColor` as a shortcut for distinct interactive state colors.
- Treat `@media (forced-colors: active)` overrides as the primary accessibility strategy.

## Related Rules

- [3-3 CSS Custom Properties for Theming](3-3-css-custom-properties.md)
- [3-6 Geometry-Only Inline Styles Policy](3-6-geometry-inline-styles.md)
