---
title: Annotate Parent Static Styles as CSSResultGroup to Allow Subclass Arrays
priority: HIGH
category: Styling
---

# Annotate Parent Static Styles as CSSResultGroup

## Rule

When a Lit parent class has a `static styles` property inferred as `CSSResult`, a subclass
that tries to extend it with an array gets **TS2417**. Fix this by annotating the parent's
declaration explicitly as `CSSResultGroup`.

## The error

```ts
// Parent — inferred as CSSResult
static override styles = baseStyles;

// Subclass — TS2417: CSSResult[] is not assignable to CSSResult
static override styles = [ParentClass.styles, childStyles];
```

TypeScript's class property override rule requires the child's declared type to be
assignable to the parent's. `CSSResult[]` does not extend `CSSResult`, even though both
are valid `CSSResultGroup` values.

## Fix

Annotate the **parent**'s declaration with the wider union type:

```ts
import type { CSSResultGroup } from 'lit';

// Parent
static override styles: CSSResultGroup = baseStyles;

// Subclass — no TS2417 now
static override styles: CSSResultGroup = [ParentClass.styles, childStyles];
```

## Why CSSResultGroup

`CSSResultGroup = CSSResult | CSSResultArray` where `CSSResultArray = Array<CSSResultGroup>`.
Lit's renderer accepts both forms. Declaring the parent property as the wider union allows
any subclass to pass either a single result or an array without a type violation.

## Notes

- The annotation must be on the **parent**; TypeScript's override check compares against the
  parent's declared type, so annotating only the child is insufficient.
- Safe to add: Lit's internal style handling accepts `CSSResultGroup` in all supported versions.
- Applies whenever you subclass any Lit component and need to add or replace styles.
