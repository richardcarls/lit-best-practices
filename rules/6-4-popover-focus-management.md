---
title: Popover Focus Return Management
impact: HIGH
impactDescription: hidePopover() asynchronously returns focus to the previously focused element, which can re-trigger open handlers and cause infinite open/close loops
tags: popover, focus, accessibility, keyboard, combobox, browser-behavior
---

## Popover Focus Return Management

When `showPopover()` is called, browsers record the currently focused element. When `hidePopover()`
is called, some browsers (Firefox especially) **asynchronously return focus** to that element,
dispatching a `focus` event after `hidePopover()` has already returned.

If the element that triggered the popover is still focused when the popup closes, this async `focus`
event hits your `_handleInputFocus` (or equivalent) handler; which re-opens the popup. The result is
an infinite open/close loop that is invisible in synchronous code review.

**Incorrect:**

```typescript
private _handleInputFocus = () => {
  this.openPopup(); // re-triggered by hidePopover()'s async focus return
};

private _handleCloseClick = () => {
  this.hidePopover(); // focus returns to input → _handleInputFocus fires → openPopup()
};
```

**Correct; use a closing flag:**

```typescript
private _closingPopup = false;

private _handleInputFocus = () => {
  if (this._closingPopup) return; // ignore the focus event caused by hidePopover

  this.openPopup();
};

private _closePopup() {
  this._closingPopup = true;

  this.hidePopover();

  // Reset after async focus events have settled; 0 ms outlasts async focus
  setTimeout(() => {
    this._closingPopup = false;
  }, 0);
}
```

**Why `setTimeout(0)` and not `queueMicrotask`?**

Browser focus events from `hidePopover()` fire as part of browser-internal task processing; after
the current task's microtask checkpoint. `queueMicrotask` runs at the end of the current task but
before the next browser task, so the flag resets before the browser's async focus event arrives.
`setTimeout(0)` schedules a macrotask, which runs after the browser finishes its focus-return
processing. Use `setTimeout(0)` here, not `queueMicrotask`.

**Testing implication:** In browser tests, dispatching `KeyboardEvent` on an element does NOT give
it browser focus. But `_handleInputFocus` only fires on real DOM `focus` events. Call
`input.focus()` explicitly at the start of keyboard-navigation tests so that:

1. `_handleInputFocus` fires via the real browser path, opening the popup
1. The input is the "previously focused element" recorded by `showPopover()`
1. `hidePopover()` returns focus to the already-focused input; no net focus change, no spurious re-open

```typescript
it('closes on Escape', async () => {
  const host = await fixture<MyCombobox>(html`<my-combobox></my-combobox>`);
  const input = host.shadowRoot!.querySelector('input')!;

  // Establish real browser focus so hidePopover() has a safe return target
  input.focus();
  await host.updateComplete;

  input.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
  await host.updateComplete;

  expect(host.open).to.be.false;
});
```

**Related browser quirk; `getByRole` and popover siblings:**

`getByRole('combobox')` (WebDriverIO / Testing Library) can time out in Firefox when a
`[popover="manual"]` element is a sibling in the same shadow root. Prefer direct shadow DOM queries
in browser tests:

```typescript
async function getHost(screen): Promise<MyCombobox> {
  const host = screen.container.querySelector('my-combobox') as MyCombobox;
  await host.updateComplete;
  return host;
}
```
