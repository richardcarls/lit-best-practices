---
title: Defer DOM Mutations in Slotchange Handlers
impact: CRITICAL
impactDescription: Synchronous DOM mutations inside slotchange handlers can re-enter a host framework's reactive update pass, causing hard-to-diagnose loops or focus cascades
tags: slots, slotchange, queueMicrotask, shadow-dom, lifecycle, framework-interop
---

## Defer DOM Mutations in Slotchange Handlers

A `slotchange` event can fire **synchronously inside a host framework's reactive update pass** — not just on first mount. On second+ mount (user navigates back to a route, component is re-inserted), the shadow DOM persists across `disconnectedCallback`/`connectedCallback`. When the framework re-inserts a slotted child, the browser immediately assigns it and fires `slotchange` synchronously, while the framework is still processing its own update.

Any DOM mutation inside that handler — `focus()`, `setAttribute`, property setters — executes during the framework update. `focus()` is especially dangerous: it dispatches `focusin`/`focusout` events that framework delegate listeners may intercept, re-entering the reactive system.

**Incorrect:**

```typescript
private _onSlotChange = (e: Event) => {
  const slot = e.target as HTMLSlotElement;
  const items = slot.assignedElements() as HTMLElement[];

  this._items = items;

  // These mutations run synchronously inside the framework's update pass
  if (items.length > 0) {
    items[0].setAttribute('tabindex', '0');
    items[0].focus(); // dispatches focusin/focusout — may re-enter the reactive system
  }

  this._updateAriaAttributes(items);
};
```

**Correct:**

```typescript
private _onSlotChange = (e: Event) => {
  const slot = e.target as HTMLSlotElement;
  const items = slot.assignedElements() as HTMLElement[];

  // Cache refs synchronously — safe to read during any phase
  this._items = items;

  if (items.length === 0) return;

  queueMicrotask(() => {
    // Guard: component may have been removed before the microtask runs
    if (!this.isConnected) return;

    items[0].setAttribute('tabindex', '0');
    items[0].focus();
    this._updateAriaAttributes(items);
  });
};
```

**Rule:**

- **Read synchronously** — call `slot.assignedElements()` and cache WeakRefs in the handler body.
- **Defer everything else** — all `setAttribute`, `removeAttribute`, property setters, `focus()`, and observer setup go inside `queueMicrotask`.
- **Always guard with `isConnected`** — the component may be removed between the slotchange and the microtask.

**Pattern for components with MutationObservers:**

```typescript
private _onSlotChange = (e: Event) => {
  const slot = e.target as HTMLSlotElement;
  const el =
    slot.assignedElements().find((n): n is HTMLSelectElement => n instanceof HTMLSelectElement) ?? null;

  // Synchronous cleanup is fine — no DOM mutation, just internal state
  this._observer?.disconnect();
  this._observer = null;
  this._elRef = el ? new WeakRef(el) : null;

  if (!el) return;

  queueMicrotask(() => {
    if (!el.isConnected) return;

    this.disabled = el.disabled;
    this._syncFromElement(el);
    this._observer = new MutationObserver(() => {
      const target = this._elRef?.deref();
      if (target) this._syncFromElement(target);
    });
    this._observer.observe(el, { childList: true, subtree: true, attributes: true });
  });
};
```

**Why `queueMicrotask` and not `requestAnimationFrame`?**

`requestAnimationFrame` defers until before the next paint — useful for layout-dependent work. `queueMicrotask` flushes at the end of the current task, before any macrotask or paint. For slot initialization work that is reactive but not layout-dependent, the microtask queue is the right choice: it exits the framework's synchronous update pass while staying as close as possible to the triggering event.

**Test impact:** `await host.updateComplete` does not flush the microtask queue. Tests that interact with deferred slot state immediately after `updateComplete` will see an empty/uninitialized component. Add a microtask flush after `updateComplete` in any test helper that returns a freshly rendered host — see rule `10-3-await-update-complete.md`.
