---
title: Test Slot Content Rendering
impact: MEDIUM
impactDescription: Querying shadow DOM for slotted elements always returns null; slot assertions need the slot API
tags: testing, slots, slotted-content, assignedElements, light-dom
---

## Test Slot Content Rendering

Slotted content lives in the light DOM (on the host), not in the shadow DOM. Shadow DOM queries will never find it. Assert on the host's children and use the slot API to verify distribution.

**Incorrect:**

```typescript
it('displays the slotted heading', async () => {
  const el = await fixture<MyCard>(html`
    <my-card>
      <h2 slot="heading">Card Title</h2>
    </my-card>
  `);

  // Wrong: searches shadow DOM — slotted elements are not in shadow DOM
  const heading = el.shadowRoot!.querySelector('h2');
  expect(heading).to.exist;          // fails — returns null
  expect(heading?.textContent).to.equal('Card Title');
});
```

**Correct:**

```typescript
it('distributes the heading slot', async () => {
  const el = await fixture<MyCard>(html`
    <my-card>
      <h2 slot="heading">Card Title</h2>
    </my-card>
  `);
  await el.updateComplete;

  // Assert on the light DOM child (it's a child of el, not of shadowRoot)
  const heading = el.querySelector('h2');
  expect(heading).to.exist;
  expect(heading?.textContent?.trim()).to.equal('Card Title');
});

it('assigns content to the named slot', async () => {
  const el = await fixture<MyCard>(html`
    <my-card>
      <span slot="icon">★</span>
      <p>Body text</p>
    </my-card>
  `);
  await el.updateComplete;

  // Read assigned elements from the slot in shadow DOM
  const iconSlot = el.shadowRoot!.querySelector<HTMLSlotElement>('slot[name="icon"]')!;
  const defaultSlot = el.shadowRoot!.querySelector<HTMLSlotElement>('slot:not([name])')!;

  expect(iconSlot.assignedElements()).to.have.lengthOf(1);
  expect(defaultSlot.assignedElements()).to.have.lengthOf(1);
  expect(defaultSlot.assignedElements()[0].tagName).to.equal('P');
});
```

**Test slot fallback content:**

```typescript
it('renders fallback when slot is empty', async () => {
  // No children — default slot fallback should show
  const el = await fixture<MyCard>(html`<my-card></my-card>`);
  await el.updateComplete;

  const defaultSlot = el.shadowRoot!.querySelector<HTMLSlotElement>('slot:not([name])')!;
  expect(defaultSlot.assignedElements()).to.have.lengthOf(0); // nothing assigned

  // Fallback content lives inside the <slot> element in shadow DOM
  const fallback = defaultSlot.querySelector('.fallback');
  expect(fallback).to.exist;
});
```

**Slot assertion patterns:**

| Goal | How to assert |
|------|---------------|
| Element is slotted | `el.querySelector('[slot="name"]')` exists |
| Slot received elements | `slot.assignedElements().length > 0` |
| Correct element assigned | `slot.assignedElements()[0].tagName` or text content |
| Fallback renders when empty | `slot.assignedElements().length === 0` + fallback query |
