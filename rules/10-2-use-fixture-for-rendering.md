---
title: Use fixture() for Component Instantiation
impact: HIGH
impactDescription: document.createElement skips rendering, leaving shadow DOM empty and update lifecycle incomplete
tags: testing, fixture, open-wc, rendering, instantiation
---

## Use fixture() for Component Instantiation

`fixture()` from `@open-wc/testing` connects the element to a real document, waits for the first render cycle, and registers cleanup after each test. `document.createElement` does none of these — the shadow DOM is empty and `firstUpdated` never runs.

**Incorrect:**

```typescript
it('shows the label', () => {
  // createElement does not trigger rendering
  const el = document.createElement('my-button') as MyButton;
  el.label = 'Submit';
  // shadowRoot exists but is empty — render() has not run
  const btn = el.shadowRoot?.querySelector('button');
  expect(btn?.textContent).to.equal('Submit'); // fails
});
```

```typescript
it('renders with properties', async () => {
  // Manually connecting still misses firstUpdated timing
  const el = document.createElement('my-button') as MyButton;
  document.body.appendChild(el);
  expect(el.shadowRoot?.querySelector('button')).to.exist; // may be null
  document.body.removeChild(el); // manual cleanup — easy to forget
});
```

**Correct:**

```typescript
import { fixture, expect, html } from '@open-wc/testing';

it('shows the label', async () => {
  // fixture() connects the element, waits for updateComplete, handles cleanup
  const el = await fixture<MyButton>(html`<my-button label="Submit"></my-button>`);
  const btn = el.shadowRoot!.querySelector('button');
  expect(btn?.textContent?.trim()).to.equal('Submit');
});

it('reflects the disabled property', async () => {
  const el = await fixture<MyButton>(html`<my-button disabled></my-button>`);
  expect(el.hasAttribute('disabled')).to.be.true;
});
```

**With initial children (slot content):**

```typescript
it('renders slotted content', async () => {
  const el = await fixture<MyCard>(html`
    <my-card>
      <span slot="header">Title</span>
      <p>Body text</p>
    </my-card>
  `);
  const header = el.querySelector('[slot="header"]');
  expect(header?.textContent).to.equal('Title');
});
```

**fixture() vs alternatives:**

| Method | Renders? | Awaits update? | Cleans up? | Use when |
|--------|----------|----------------|------------|----------|
| `await fixture(html\`...\`)` | Yes | Yes | Yes | Always — default choice |
| `fixtureSync(html\`...\`)` | Yes | No | Yes | Synchronous setup before awaiting manually |
| `document.createElement` | No | No | No | Never in Lit component tests |

`fixture()` appends to a `<div>` in the document body and removes it in an `afterEach` hook — tests are automatically isolated without manual cleanup.
