---
title: Slot Composition Patterns
impact: HIGH
impactDescription: Treating slotted content as owned children causes incorrect behavior and missed updates
tags: slots, composition, light-dom, slotchange, assignedElements
---

## Slot Composition Patterns

Slotted content is distributed light DOM; it belongs to the parent document, not the component. Read
it through the slot API; never query or iterate `this.children` directly.

**Incorrect:**

```typescript
// Searching shadow DOM won't find slotted content
firstUpdated() {
  const items = this.shadowRoot?.querySelectorAll('li'); // always empty
  this._count = this.children.length;                   // includes text nodes, not reactive
}

render() {
  // Cloning slotted children breaks their event listeners and reactivity
  return html`
    <ul>
      ${Array.from(this.children).map(child => html`<li>${child}</li>`)}
    </ul>
  `;
}
```

**Correct:**

```typescript
@customElement('item-list')
export class ItemList extends LitElement {
  @query('slot') private _slot?: HTMLSlotElement;

  @state() private _itemCount = 0;

  firstUpdated() {
    this._slot?.addEventListener('slotchange', this._onSlotChange);
  }

  private _onSlotChange = () => {
    this._itemCount = this._slot?.assignedElements({ flatten: true }).length ?? 0;
  };

  render() {
    return html`
      <p>${this._itemCount} items</p>
      <slot></slot>
    `;
  }
}
```

**Slot API methods:**

| Method | Returns | Use when |
| -------- | --------- | ---------- |
| `slot.assignedNodes()` | Text nodes + elements | Need raw DOM nodes |
| `slot.assignedElements()` | Elements only | Need element references (most common) |
| `slot.assignedElements({ flatten: true })` | Elements including re-slotted content | Nested slot composition |

**Named slots:**

```typescript
render() {
  return html`
    <header><slot name="header"></slot></header>
    <main><slot></slot></main>
    <footer><slot name="footer"></slot></footer>
  `;
}
```

```html
<!-- Consumer -->
<my-layout>
  <h1 slot="header">Title</h1>
  <p>Body content</p>
  <nav slot="footer">Links</nav>
</my-layout>
```

**Style slotted content with `::slotted()`:**

```typescript
static styles = css`
  ::slotted(*) { margin: 0; }
  ::slotted(p) { color: var(--text-color); }
`;
```

Note: `::slotted()` only matches direct slotted children; it cannot pierce nested shadow roots.
