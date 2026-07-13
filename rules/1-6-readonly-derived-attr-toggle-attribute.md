---
title: Reflect a Read-Only Derived Boolean with toggleAttribute
impact: MEDIUM
impactDescription: Avoids exposing a public setter or triggering Lit re-render loops for state that is only ever derived
tags: reflected-attribute, lifecycle, css-selectors, updated
---

## Reflect a Read-Only Derived Boolean with toggleAttribute

When a component needs a read-only boolean attribute that reflects derived state
(for example, `has-value`, `empty`, `dirty`, `invalid`) for use in CSS selectors or external
integrations, avoid `@property({ type: Boolean, reflect: true })`:

- A `@property` without a setter makes the property publicly writable, violating
  read-only semantics.
- Writing to a `@property` inside `willUpdate()` or `updated()` re-queues another
  Lit update, which can cause infinite re-render cycles if not guarded carefully.

**Instead:** call `this.toggleAttribute('attr-name', derivedBoolean)` inside
`override updated(changed: PropertyValues)`:

```ts
override updated(changed: PropertyValues) {
  super.updated(changed);
  this.toggleAttribute('has-value', this._selectedValues.size > 0);
}
```

`toggleAttribute` is a raw DOM call; it does not touch Lit's reactive property system
and never queues another update.

**ARIA attributes are excluded.** `toggleAttribute(name, true)` sets the attribute to an
empty string (`""`), not `"true"`. HTML boolean attributes (`disabled`, `hidden`, `required`,
custom data attributes for CSS selectors) are fine with presence/absence semantics. ARIA
boolean attributes (`aria-expanded`, `aria-multiselectable`, `aria-pressed`, `aria-selected`,
etc.) require explicit string values `"true"` or `"false"`; use `setAttribute` / `removeAttribute`
for those:

```ts
override updated() {
  if (this.multiple) {
    this.setAttribute('aria-multiselectable', 'true');
  } else {
    this.removeAttribute('aria-multiselectable');
  }
}
```

The attribute stays in sync automatically because Lit calls `updated()` on every render cycle,
and the source state (a `@state()` field) triggers renders whenever it changes.

**Document it with `@attr` JSDoc** in the class block (not as a `@property` decorator)
so a Custom Elements Manifest analyzer omits a writable property entry while still making the
attribute visible in documentation:

```ts
 * @attr [has-value] - Present when one or more options are selected.
```
