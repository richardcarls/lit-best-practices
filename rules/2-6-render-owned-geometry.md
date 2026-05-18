---
title: Let render() Own Template Geometry
impact: HIGH
impactDescription: Prevents external style writes from being overwritten by Lit's next render
tags: rendering, geometry, inline-styles, lifecycle, reactive-state
---

## Let render() Own Template Geometry

If a template binds a geometry value through `style`, `styleMap`, `classMap`, or an attribute,
Lit owns that value. External callbacks such as `customElements.whenDefined(...).then(...)`,
`firstUpdated`, observers, or consumers should update reactive state or public properties, not
write directly to the same DOM style.

**Incorrect:**

```typescript
customElements.whenDefined('range-thumb').then(() => {
  document.querySelector('range-thumb')!.style.left = '25%';
});
```

```typescript
render() {
  return html`
    <div class="thumb" style="left:${this._position}%"></div>
  `;
}
```

The direct `style.left` write appears to work until Lit renders again. The next update
re-applies the template value and silently overwrites the external write.

**Correct:**

```typescript
@property({ type: Number }) position = 0;

render() {
  return html`
    <div class="thumb" style="left:${this.position}%"></div>
  `;
}
```

```typescript
const thumb = document.querySelector('range-thumb')!;
thumb.position = 25;
```

For measured geometry, store the measured value in `@state()` and render from that state:

```typescript
@state() private _measuredWidth = 0;

private readonly _observer = new ResizeObserver(([entry]) => {
  this._measuredWidth = entry.contentRect.width;
});

render() {
  return html`
    <div style="width:${this._measuredWidth}px"></div>
  `;
}
```

Direct DOM geometry writes are only safe when Lit's template never controls the same property.
