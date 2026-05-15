---
id: 3-6
title: Geometry-Only Inline Styles Policy
category: Styling
priority: HIGH
tags: [css, inline-styles, styling, web-components, design-system]
description: Reserve inline styles for runtime-measured geometry; put visual styling in CSS or custom properties
---

## Problem

Inline styles bypass the cascade and custom property inheritance. A component that sets
`style="color: red; border: 1px solid #ccc"` cannot be themed by consumers without
`!important`, can break forced-colors mode, and cannot be overridden with `::part()`
selectors.

## Rule

Inline styles are permitted only for runtime-measured geometry:

- Dimensions derived from `getBoundingClientRect()` or `ResizeObserver`.
- Position or transform values computed from pointer movement during drag.
- Custom properties set from JavaScript measurement, such as `--splitter-position: 240px`.

Everything else belongs in static CSS, CSS classes, reflected attributes, or CSS custom
properties:

- Colors.
- Typography.
- Borders.
- Shadows.
- Backgrounds.

## Correct

```typescript
private onPointerMove(event: PointerEvent): void {
  const offset = event.clientX - this.dragStart;

  this.style.setProperty("--splitter-position", `${offset}px`);
}
```

For dynamic visual state, expose state through an attribute or property and let CSS style it:

```typescript
this.toggleAttribute("selected", this.isSelected);
```

```css
:host([selected]) .item {
  background: var(--component-selected, Highlight);
  color: var(--component-selected-text, HighlightText);
}
```

## Incorrect

```typescript
private updateStyle(): void {
  this.style.backgroundColor = this.isSelected ? "#3b82f6" : "#f0f0f0";
  this.style.border = "1px solid rgba(0, 0, 0, 0.2)";
}
```

## Pointer Event Directives

Pointer or mouse event directives often appear near inline geometry code. Prefer
`pointermove` plus pointer capture over legacy `mousemove` listeners when implementing drag:

```typescript
element.addEventListener("pointermove", this.onMove);
element.setPointerCapture(event.pointerId);
```

## Do Not Do

- Set `style.color`, `style.border`, or `style.boxShadow` from JavaScript.
- Use `el.style.setProperty("--color-x", "#fff")` for design values.
- Read computed styles to make styling decisions; derive state from data instead.

## Related Rules

- [3-3 CSS Custom Properties for Theming](3-3-css-custom-properties.md)
- [3-5 CSS System Colors for Forced Colors Mode](3-5-css-system-colors.md)
