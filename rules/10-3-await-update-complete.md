---
title: Await updateComplete Before DOM Assertions
impact: HIGH
impactDescription: Asserting before the render cycle completes reads stale DOM and produces false positives
tags: testing, updateComplete, async, rendering, assertions
---

## Await updateComplete Before DOM Assertions

Lit's rendering is asynchronous. Setting a property enqueues an update — the DOM reflects that change only after `updateComplete` resolves. Asserting immediately after a property change reads the previous render.

**Incorrect:**

```typescript
it('shows error state', async () => {
  const el = await fixture<MyInput>(html`<my-input></my-input>`);

  el.error = 'Required field';
  // DOM not updated yet — the error message hasn't rendered
  const msg = el.shadowRoot!.querySelector('.error-message');
  expect(msg).to.exist;       // fails — element not in DOM yet
  expect(msg?.textContent).to.equal('Required field'); // fails
});
```

```typescript
it('disables the button', async () => {
  const el = await fixture<MyForm>(html`<my-form></my-form>`);
  el.submitting = true;
  const btn = el.shadowRoot!.querySelector('button');
  expect(btn?.disabled).to.be.true; // false — render hasn't happened
});
```

**Correct:**

```typescript
it('shows error state', async () => {
  const el = await fixture<MyInput>(html`<my-input></my-input>`);

  el.error = 'Required field';
  await el.updateComplete; // Wait for Lit to process the property change

  const msg = el.shadowRoot!.querySelector('.error-message');
  expect(msg).to.exist;
  expect(msg?.textContent?.trim()).to.equal('Required field');
});

it('disables the button', async () => {
  const el = await fixture<MyForm>(html`<my-form></my-form>`);
  el.submitting = true;
  await el.updateComplete;

  const btn = el.shadowRoot!.querySelector('button');
  expect(btn?.disabled).to.be.true;
});
```

**Multiple property changes — one await is enough:**

```typescript
it('handles combined state', async () => {
  const el = await fixture<MyComponent>(html`<my-component></my-component>`);

  // Set multiple properties before awaiting — Lit batches into one render
  el.value = 'hello';
  el.disabled = true;
  el.error = '';
  await el.updateComplete;

  // All changes are reflected in a single render cycle
  expect(el.shadowRoot!.querySelector('input')?.value).to.equal('hello');
});
```

**When `fixture()` already handles the first await:**

`await fixture()` resolves after `updateComplete` — no extra await is needed for the initial render. Only await again after subsequent property mutations.

```typescript
const el = await fixture<MyEl>(html`<my-el value="hello"></my-el>`);
// Initial render already complete — assert directly
expect(el.shadowRoot!.querySelector('.value')?.textContent).to.equal('hello');

el.value = 'world';
await el.updateComplete; // Required for this second change
expect(el.shadowRoot!.querySelector('.value')?.textContent).to.equal('world');
```

**Slotchange-deferred state requires a microtask flush:**

When a `slotchange` handler defers its mutations via `queueMicrotask` (see rule `5-6-defer-slotchange-mutations.md`), `await host.updateComplete` is not enough — it resolves before the microtask queue drains. Tests that immediately interact with slot-driven state (clicking options, pressing arrow keys) will find an uninitialized component.

Add a microtask flush in any test helper that returns a freshly rendered host from a component that defers slot initialization:

```typescript
async function getHost(screen): Promise<MySelect> {
  const host = screen.container.querySelector('my-select') as MySelect;
  await host.updateComplete;
  await new Promise(r => setTimeout(r, 0)); // flush slotchange microtask
  return host;
}
```

`setTimeout(r, 0)` schedules a macrotask — it runs after all pending microtasks (including the `queueMicrotask` callback) have flushed.

**Write assertions that check values, not just types:**

An assertion that passes for empty or falsy inputs gives false confidence. Check concrete values:

```typescript
// Incorrect — passes for any array, including []
expect(Array.isArray(detail.value)).toBe(true);

// Correct — proves the right items were selected
expect(detail.value).toEqual(['apple', 'banana']);

// Incorrect — passes even if the handler was called with wrong arguments
expect(handler).toHaveBeenCalledOnce();

// Correct — proves both call count and argument shape
expect(handler).toHaveBeenCalledOnceWith(expect.objectContaining({ value: 'apple' }));
```
