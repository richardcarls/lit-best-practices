---
title: Query shadow DOM Elements Correctly in Tests
impact: HIGH
impactDescription: Querying the element directly instead of its shadowRoot always returns null for shadow DOM content
tags: testing, shadow-dom, querySelector, shadowRoot, queries
---

## Query shadow DOM Elements Correctly in Tests

shadow DOM content is not accessible via the host element's `querySelector`. It lives inside
`shadowRoot`; a separate DOM tree. Every shadow DOM query in tests must go through `el.shadowRoot`.

**Incorrect:**

```typescript
const el = await fixture<MyCard>(html`<my-card heading="Hello"></my-card>`);

// These all return null — querySelector on the host searches light DOM only
const heading = el.querySelector('h2');
const btn = el.querySelector('button');
const input = el.querySelector('input[name="search"]');
```

**Correct:**

```typescript
const el = await fixture<MyCard>(html`<my-card heading="Hello"></my-card>`);
await el.updateComplete;

// Query through shadowRoot
const heading = el.shadowRoot!.querySelector('h2');
const btn = el.shadowRoot!.querySelector('button');
const input = el.shadowRoot!.querySelector<HTMLInputElement>('input[name="search"]');

expect(heading?.textContent?.trim()).to.equal('Hello');
expect(btn).to.exist;
```

**Query helpers:**

```typescript
// Helper to reduce verbosity in test suites
function shadow<T extends Element>(
  el: LitElement,
  selector: string,
): T | null {
  return el.shadowRoot!.querySelector<T>(selector);
}

function shadowAll<T extends Element>(
  el: LitElement,
  selector: string,
): NodeListOf<T> {
  return el.shadowRoot!.querySelectorAll<T>(selector);
}

// Usage
const btn = shadow<HTMLButtonElement>(el, 'button[type="submit"]');
const items = shadowAll<HTMLLIElement>(el, 'li');
```

**Querying nested components:**

```typescript
const app = await fixture<AppRoot>(html`<app-root></app-root>`);
await app.updateComplete;

// Step into each shadow root level
const nav = app.shadowRoot!.querySelector('app-nav') as AppNav;
await nav.updateComplete;

const link = nav.shadowRoot!.querySelector('a[href="/home"]');
expect(link).to.exist;
```

**light DOM vs shadow DOM:**

| Target | Use |
| -------- | ----- |
| shadow DOM content (rendered template) | `el.shadowRoot!.querySelector(...)` |
| Slotted light DOM content | `el.querySelector(...)` or slot API |
| Attributes on the host element itself | `el.getAttribute(...)` / `el.hasAttribute(...)` |

**Note:** `@open-wc/testing`'s `expect(el).shadowDom.to.equalSnapshot()` inspects shadow DOM
automatically; use it for snapshot testing instead of manual queries.
