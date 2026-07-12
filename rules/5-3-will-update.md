---
title: Use willUpdate for Derived State and Invariants
impact: HIGH
impactDescription: Avoids extra render cycles, computed state and invariants ready before render
tags: lifecycle, state, performance, derived-state, invariants
---

## Use willUpdate for Derived State and Invariants

Calculate derived state and cross-property invariants in `willUpdate`, not `updated`.

**Incorrect (triggers extra render):**

```typescript
@state() sortedItems: Item[] = [];
@state() itemCount = 0;

updated(changedProperties: PropertyValues) {
  if (changedProperties.has('items')) {
    // This triggers another render cycle!
    this.sortedItems = [...this.items].sort(compareItems);
    this.itemCount = this.items.length;
  }
}
```

**Correct (no extra render):**

```typescript
@state() private _sortedItems: Item[] = [];
@state() private _itemCount = 0;

willUpdate(changedProperties: PropertyValues) {
  if (changedProperties.has('items')) {
    // Runs before render, no extra cycle
    this._sortedItems = [...this.items].sort(compareItems);
    this._itemCount = this.items.length;
  }
}

render() {
  return html`
    <p>Total: ${this._itemCount}</p>
    <ul>
      ${this._sortedItems.map(item => html`<li>${item.name}</li>`)}
    </ul>
  `;
}
```

**Lifecycle timing:**

| Method | When | Use for |
| -------- | ------ | --------- |
| `willUpdate` | Before render | Compute derived state |
| `render` | During update | Return template |
| `updated` | After render | Side effects, DOM operations, events |

Setting `@state()` or `@property()` values in `updated` triggers a new update cycle. Do this only
when intentional (rare).

**Cross-property invariants:**

Use `willUpdate(changedProperties)` when multiple reactive values must be reconciled before
the DOM is rendered. It runs synchronously before every render, including the first render,
and `changedProperties` contains all initially set properties on that first call.

```typescript
willUpdate(changedProperties: PropertyValues<this>) {
  if (changedProperties.has('value') || changedProperties.has('min') || changedProperties.has('max')) {
    const [lo, hi] = this.value;
    const clampedLo = Math.max(this.min, Math.min(lo, hi));
    const clampedHi = Math.min(this.max, Math.max(hi, clampedLo));

    if (clampedLo !== lo || clampedHi !== hi) {
      this.value = [clampedLo, clampedHi];
    }
  }
}
```

This guarantees constraints like `min <= value[0] <= value[1] <= max` before every render,
with no first-paint flicker and no extra update cycle.
