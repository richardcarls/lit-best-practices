---
title: Separate Public Properties from Internal State
impact: HIGH
impactDescription: Clear API boundaries, reduced attribute overhead, better encapsulation
tags: state-management, encapsulation, api-design
---

## Separate Public Properties from Internal State

Use `@property()` for public API and `@state()` for internal state.

**Incorrect (mixing concerns):**

```typescript
@customElement('my-dropdown')
export class MyDropdown extends LitElement {
  @property({ type: Boolean }) isOpen = false;
  @property({ type: Number }) selectedIndex = -1;
  @property({ type: Array }) _filteredItems = [];
  @property({ type: String }) _searchQuery = '';
}
```

**Correct (clear separation):**

```typescript
@customElement('my-dropdown')
export class MyDropdown extends LitElement {
  // Public API
  @property({ type: Array }) items: DropdownItem[] = [];
  @property({ type: String }) value = '';
  @property({ type: Boolean, reflect: true }) open = false;
  @property({ type: Boolean, reflect: true }) disabled = false;
  
  // Internal state
  @state() private _filteredItems: DropdownItem[] = [];
  @state() private _searchQuery = '';
  @state() private _highlightedIndex = -1;
}
```

This pattern:

- Makes the component's public API clear
- Prevents external code from depending on internal state
- Reduces attribute handling overhead for internal state

**`@state()` equality trap; Set and Map mutations:**

Lit uses `Object.is()` to compare old and new values before deciding whether to re-render. Mutating
a `Set` or `Map` in place (`.add()`, `.delete()`, `.set()`) does not change the reference;
`Object.is(prev, next)` returns `true`, and Lit skips the render.

```typescript
// Incorrect — mutation does not trigger re-render
private _selected = new Set<string>();

toggle(id: string) {
  if (this._selected.has(id)) {
    this._selected.delete(id); // same Set reference — no update scheduled
  } else {
    this._selected.add(id);    // same Set reference — no update scheduled
  }
}

// Correct — replace the reference so Object.is() returns false
@state() private _selected = new Set<string>();

toggle(id: string) {
  const next = new Set(this._selected);
  if (next.has(id)) {
    next.delete(id);
  } else {
    next.add(id);
  }
  this._selected = next; // new reference → requestUpdate() fires
}
```

The same applies to `Map`, arrays mutated via `.push()`/`.splice()`, and plain objects mutated via
property assignment. Always replace the reference rather than mutating in place.
