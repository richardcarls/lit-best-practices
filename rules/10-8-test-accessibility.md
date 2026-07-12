---
title: Test Accessibility with axe-core
impact: MEDIUM
impactDescription: Manual ARIA review misses rule combinations; automated axe scans catch the majority of violations before they ship
tags: testing, accessibility, axe-core, aria, open-wc, a11y
---

## Test Accessibility with axe-core

`@open-wc/testing` bundles axe-core via the `expect(el).to.be.accessible()` assertion. Running it on
every interactive component catches missing ARIA attributes, incorrect roles, focus management
issues, and color contrast problems automatically.

**Incorrect:**

```typescript
// Manual spot-checks miss most violation combinations
it('is accessible', async () => {
  const el = await fixture<MyCheckbox>(html`<my-checkbox label="Accept terms"></my-checkbox>`);

  // Only checks one attribute — passes even if role, tabindex, or keyboard is wrong
  expect(el.shadowRoot!.querySelector('input')?.getAttribute('aria-label'))
    .to.equal('Accept terms');
});
```

**Correct:**

```typescript
import { fixture, expect, html } from '@open-wc/testing';

describe('MyCheckbox accessibility', () => {
  it('is accessible in default state', async () => {
    const el = await fixture<MyCheckbox>(html`
      <my-checkbox label="Accept terms"></my-checkbox>
    `);
    await el.updateComplete;

    await expect(el).to.be.accessible();
  });

  it('is accessible when checked', async () => {
    const el = await fixture<MyCheckbox>(html`
      <my-checkbox label="Accept terms" checked></my-checkbox>
    `);
    await el.updateComplete;

    await expect(el).to.be.accessible();
  });

  it('is accessible when disabled', async () => {
    const el = await fixture<MyCheckbox>(html`
      <my-checkbox label="Accept terms" disabled></my-checkbox>
    `);
    await el.updateComplete;

    await expect(el).to.be.accessible();
  });
});
```

**Custom axe rules and ignore lists:**

```typescript
// Ignore a specific rule when there is a documented reason
await expect(el).to.be.accessible({
  ignoredRules: ['color-contrast'], // e.g., colors come from host page, not component
});

// Run a specific subset of rules
await expect(el).to.be.accessible({
  runOnly: { type: 'rule', values: ['aria-required-attr', 'aria-valid-attr'] },
});
```

**What axe-core checks automatically:**

| Category | Examples |
| ---------- | --------- |
| ARIA | Missing required attributes, invalid values, role conflicts |
| Focus | Interactive elements with `tabindex="-1"`, missing focus management |
| Images | Missing `alt` attributes |
| Forms | Missing labels, implicit label associations |
| Color | Insufficient contrast ratio (requires visible text) |
| Structure | Missing landmarks, heading order |

**Test states that change ARIA:**

Interactive components should be tested in every meaningful state (default, checked/selected,
disabled, error) because ARIA attributes differ per state and violations may only appear in specific
combinations.
