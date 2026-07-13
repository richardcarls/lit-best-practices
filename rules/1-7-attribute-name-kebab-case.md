---
title: Attribute Names Are Literal; Set Explicit Kebab-Case for Multi-Word Properties
impact: HIGH
impactDescription: Lit's default attribute derivation silently collapses camelCase to a lowercase run with no hyphens, causing kebab-case markup to miss the property entirely
tags: attributes, camelcase, kebab, boolean, JSX
---

## Attribute Names Are Literal; Set Explicit Kebab-Case for Multi-Word Properties

Lit's default attribute derivation lowercases the property name but does **not** insert hyphens.
`allowCreate` becomes the attribute `allowcreate`, never `allow-create`.

This surprises HTML authors and JSX consumers who expect kebab-case (`allow-create`) following
the normal custom-element attribute convention. Writing `allow-create` sets a completely
different attribute and the property stays at its default value; silently.

```ts
// Default Lit behavior — attribute is "allowcreate", not "allow-create"
@property({ type: Boolean })
allowCreate = false;

// Bug: sets DOM attribute "allow-create" — allowCreate property stays false
<my-combobox allow-create>
```

## Fix

Explicitly set the `attribute:` option to the kebab-case form:

```ts
@property({ type: Boolean, attribute: 'allow-create' })
allowCreate = false;
```

Now HTML and JSX consumers can use `allow-create` as expected:

```html
<my-combobox allow-create>...</my-combobox>
```

## Why kebab-case specifically (not just "explicit")

Kebab-case is a custom element best practice for a second reason beyond readability: future
HTML attribute additions may collide with all-lowercase single-token names. The HTML spec
adds new attributes like `disabled`, `hidden`, and `inert` over time. A component attribute
named `allowcreate` could collide if a future spec ever adds that word as a global attribute.
Hyphenated names (`allow-create`) are safe because the HTML spec reserves hyphenated attribute
names for custom use.

## Why Lit's default is lowercase-only

Lit differs from Angular, Vue, and Stencil, which convert `allowCreate` → `allow-create` by
default. Lit's source is `name.toString().toLowerCase()`; no kebab transform.

## Rule

For any multi-word `@property` on a public component, always provide an explicit
`attribute: 'kebab-case-name'` option:

1. **Consumer expectation**; Lit's default produces `allowcreate`, not `allow-create`.
   HTML authors and JSX consumers expect kebab-case; the collapsed form is a silent mismatch.
1. **Future-collision safety**; hyphenated names are reserved for custom use and are
   collision-safe against future global attributes.

Single-word properties (for example, `open`, `multiple`, `disabled`) are fine with the default;
`open.toLowerCase()` === `open`; though watch for collision with existing global attributes.

## Do not do

- Rely on Lit's default attribute derivation for camelCase property names
- Write the attribute name by hand-lowercasing the property name; apply kebab-case instead
- Assume Lit mirrors other framework attribute-name conventions
