---
title: Rich Data Properties
priority: HIGH
category: Custom Element Interop/API Design
---

# Rich Data Properties

## Rule

Expose object, array, callback, plugin, and controller-style configuration as properties only. Reflect only primitive state to attributes when it is useful for CSS, SSR, or HTML authoring.

## Incorrect

```ts
@property({ type: Array, reflect: true }) options: Option[] = [];
@property({ type: Object, reflect: true }) plugin?: TextPlugin;
```

```html
<wc-select options="[{&quot;value&quot;:&quot;a&quot;,&quot;label&quot;:&quot;Alpha&quot;}]"></wc-select>
```

## Correct

```ts
@property({ attribute: false }) options: Option[] = [];
@property({ attribute: false }) plugin: TextPlugin | null = null;
@property({ type: Boolean, reflect: true }) disabled = false;
```

```tsx
<wc-select prop:options={options()} prop:value={value()} />
<wc-textarea prop:plugin={markdownPlugin} />
```

## Why It Matters

Attributes are strings. Reflecting rich data produces lossy serialization, reentrancy hazards, and fragile framework behavior. Property-only rich APIs let React, Solid, Vue, and plain JavaScript pass live objects while simple attributes remain available for primitive state.

## Related Rules

- [1-3 Reflect Properties Sparingly](1-3-reflect-sparingly.md)
- [7-1 Custom hasChanged for Complex Types](7-1-has-changed.md)
- [11-1 Controlled and Default APIs](11-1-controlled-default-apis.md)
