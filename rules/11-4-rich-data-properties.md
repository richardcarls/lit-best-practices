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

## requestUpdate() for Array/Object Properties

Call `requestUpdate()` (no args) rather than `requestUpdate('propertyName', oldValue)` for
array and object properties. With named-property dirty checking, Lit compares old vs. new by
`===`. If a consumer passes a freshly allocated array each render (common in Solid memos and
React), the references differ and rendering always happens correctly — but if the consumer
mutates the existing array in-place, Lit skips the render because same reference = no change.
No-arg `requestUpdate()` bypasses dirty checking entirely and is always safe for external state:

```ts
@property({ attribute: false })
set decorations(value: DecorationInput[] | undefined) {
  this._externalDecorations = value ?? [];
  this.requestUpdate();  // no-args: bypasses dirty-check, always schedules a render
}
```

## Related Rules

- [1-3 Reflect Properties Sparingly](1-3-reflect-sparingly.md)
- [7-1 Custom hasChanged for Complex Types](7-1-has-changed.md)
- [11-1 Controlled and Default APIs](11-1-controlled-default-apis.md)
