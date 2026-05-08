---
title: Test Custom Events with oneEvent()
impact: HIGH
impactDescription: Raw addEventListener + Promise wrappers miss timing edge cases and produce flaky tests
tags: testing, custom-events, oneEvent, event-assertions, open-wc
---

## Test Custom Events with oneEvent()

`oneEvent()` from `@open-wc/testing` returns a `Promise` that resolves when the named event fires. It correctly handles events that fire synchronously during the trigger action and avoids the race condition in hand-written Promise wrappers.

**Incorrect:**

```typescript
// Race condition: listener added after dispatchEvent may miss synchronous events
it('dispatches value-changed', async () => {
  const el = await fixture<MyInput>(html`<my-input></my-input>`);

  let fired = false;
  el.addEventListener('value-changed', () => { fired = true; });
  el.shadowRoot!.querySelector('input')!.value = 'hello';
  el.shadowRoot!.querySelector('input')!.dispatchEvent(new Event('input'));

  expect(fired).to.be.true; // may fail if event fired synchronously before listener
});
```

```typescript
// Manual Promise wrapper — verbose and misses the event type
it('dispatches selection-changed', async () => {
  const el = await fixture<MySelect>(html`<my-select></my-select>`);

  const eventPromise = new Promise<CustomEvent>((resolve) => {
    el.addEventListener('selection-changed', (e) => resolve(e as CustomEvent));
  });
  el.selectItem('option-1');
  const event = await eventPromise;
  expect(event.detail.value).to.equal('option-1');
});
```

**Correct:**

```typescript
import { fixture, expect, html, oneEvent } from '@open-wc/testing';

it('dispatches value-changed with the new value', async () => {
  const el = await fixture<MyInput>(html`<my-input></my-input>`);
  const input = el.shadowRoot!.querySelector('input')!;

  // Register before triggering — oneEvent handles the promise correctly
  const eventPromise = oneEvent(el, 'value-changed');

  input.value = 'hello';
  input.dispatchEvent(new Event('input'));

  const event = await eventPromise as CustomEvent<{ value: string }>;
  expect(event.detail.value).to.equal('hello');
});

it('dispatches item-selected when an option is clicked', async () => {
  const el = await fixture<MyMenu>(html`
    <my-menu>
      <my-menu-item value="opt-1">Option 1</my-menu-item>
    </my-menu>
  `);

  const eventPromise = oneEvent(el, 'item-selected');
  el.shadowRoot!.querySelector<HTMLElement>('[role="option"]')!.click();

  const { detail } = await eventPromise as CustomEvent<{ value: string }>;
  expect(detail.value).to.equal('opt-1');
});
```

**Verify no event is dispatched:**

```typescript
it('does not dispatch when disabled', async () => {
  const el = await fixture<MyButton>(html`<my-button disabled></my-button>`);

  let fired = false;
  el.addEventListener('clicked', () => { fired = true; });
  el.shadowRoot!.querySelector('button')!.click();
  await el.updateComplete;

  expect(fired).to.be.false;
});
```

**Assert event properties:**

```typescript
const event = await oneEvent(el, 'change') as CustomEvent;

expect(event.bubbles).to.be.true;           // verify propagation
expect(event.composed).to.be.true;          // verify shadow DOM traversal
expect(event.detail).to.deep.equal({ value: 42 });
```
