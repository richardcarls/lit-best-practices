---
title: Use ifDefined for Conditional Attribute Removal
priority: MEDIUM
category: Rendering
---

# Use ifDefined for Conditional Attribute Removal

## Rule

When a Lit template conditionally applies an attribute and the desired falsy state is
**"attribute absent"** (not `attribute=""`), use `ifDefined(condition ? value : undefined)`
rather than returning `nothing` from the attribute expression.

## Incorrect

```ts
// `nothing` in an attribute position keeps the attribute in the DOM as an empty string
// and can trigger lit-plugin type diagnostics even though runtime behavior is close
style=${this.display === 'float' ? this._floatStyle() : nothing}
```

## Correct

```ts
// `ifDefined` removes the attribute entirely when the value is undefined
style=${ifDefined(this.display === 'float' ? this._floatStyle() : undefined)}
```

## When it matters most

- **`style` attribute**: `style=""` is subtly different from no `style` attribute — some
  external tooling or style-inheritance checks treat the empty string differently.
- **`aria-*` attributes**: absence and empty-string differ semantically for AT.
- **Boolean-like non-reflected attributes**: where the attribute's presence, not its value,
  carries meaning.

## When `nothing` is appropriate

Use `nothing` in **content position** (not attribute position) when you want to render no
node at all:

```ts
render() {
  return html`
    <div>
      ${this.showExtra ? html`<span>Extra</span>` : nothing}
    </div>
  `;
}
```

## Summary

| Expression | Attribute result |
|-----------|-----------------|
| `attr=${ifDefined(undefined)}` | attribute **removed** |
| `attr=${''}` | attribute set to empty string |
| `attr=${nothing}` | attribute set to empty string (+ lint diagnostic risk) |
