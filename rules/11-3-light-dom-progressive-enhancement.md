---
title: light DOM Progressive Enhancement
priority: HIGH
category: Custom Element Interop/API Design
---

# light DOM Progressive Enhancement

## Rule

When a custom element enhances a native control, keep the light DOM native element as a declarative
source and fallback. Capture its initial state, handle late insertion/replacement, and keep it
synchronized with the component's current state.

## Incorrect

```ts
firstUpdated() {
  const select = this.querySelector('select');
  this._options = Array.from(select?.options ?? []);
  this._value = this.getAttribute('value') ?? '';
}
```

## Correct

```ts
connectedCallback() {
  super.connectedCallback();
  this._observeLightDom();
  this._readNativeSelect();
  this._initializeSelection();
}

private _initializeSelection() {
  const nativeValue = this._readSelectedOptionsFromLightDom();
  this._uncontrolledValue = this.value ?? this.defaultValue ?? nativeValue;
  this._syncNativeSelect();
}

private _handleLightDomChanged() {
  this._readNativeSelect();
  this._preserveStillValidSelection();
  this._syncNativeSelect();
}
```

## Why It Matters

HTML authors should be able to write a useful fallback such as `<wc-select><select><option
selected>...</option></select></wc-select>`. Framework authors should also be able to replace
slotted children without racing the component. The custom element owns this timing and
synchronization work.

## Related Rules

- [1-5 Slot Composition Patterns](1-5-slot-composition.md)
- [5-6 Defer DOM Mutations in Slotchange Handlers](5-6-defer-slotchange-mutations.md)
- [11-4 Rich Data Properties](11-4-rich-data-properties.md)
