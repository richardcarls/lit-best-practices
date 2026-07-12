---
title: Async Operations with updateComplete
impact: MEDIUM
impactDescription: Ensures DOM reflects state changes before DOM manipulation
tags: async, lifecycle, dom, updateComplete
---

## Async Operations with updateComplete

Use `updateComplete` for operations that need the DOM to reflect state changes.

**Incorrect:**

```typescript
addItem(item: Item) {
  this.items = [...this.items, item];
  // DOM hasn't updated yet!
  const container = this.shadowRoot?.querySelector('.list');
  container?.scrollTo({ top: container.scrollHeight }); // Scrolls to old position
}

openDialog() {
  this.open = true;
  // Input doesn't exist yet!
  this.shadowRoot?.querySelector<HTMLInputElement>('input')?.focus();
}
```

**Correct:**

```typescript
async addItem(item: Item) {
  this.items = [...this.items, item];
  
  // Wait for render to complete
  await this.updateComplete;
  
  // Now DOM reflects new item
  const container = this.shadowRoot?.querySelector('.list');
  container?.scrollTo({
    top: container.scrollHeight,
    behavior: 'smooth'
  });
}

async openDialog() {
  this.open = true;
  await this.updateComplete;
  this.shadowRoot?.querySelector<HTMLInputElement>('input')?.focus();
}

async selectAndHighlight(id: string) {
  this.selectedId = id;
  await this.updateComplete;
  
  const element = this.shadowRoot?.querySelector(`[data-id="${id}"]`);
  element?.scrollIntoView({ behavior: 'smooth', block: 'center' });
}
```

**`updateComplete` only waits for the host component:**

`await host.updateComplete` resolves when the host element's own Lit update cycle finishes; not when
child components finish their updates. If a child's update matters for your next operation, await
its `updateComplete` separately:

```typescript
await host.updateComplete;

const listbox = host.shadowRoot!.querySelector('wc-listbox') as LitElement;
await listbox.updateComplete; // wait for the child's own render
```

This distinction is easy to miss when a component delegates rendering to child Lit elements. A test
that asserts on a child's output after only awaiting the host will read stale DOM.
