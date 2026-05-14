---
title: Silent Host Writes
priority: HIGH
category: Custom Element Interop/API Design
---

# Silent Host Writes

## Rule

Do not dispatch change or toggle events when the host application sets public properties. Dispatch composed, bubbling events only for user, native, or internal component actions that change state upward.

## Incorrect

```ts
@property({ attribute: false })
set value(next: string | string[]) {
  this._value = next;
  this.dispatchEvent(new CustomEvent('wc-select-change', { detail: { value: next } }));
}
```

## Correct

```ts
set value(next: string | string[] | undefined) {
  const old = this._value;
  this._value = next;
  this.requestUpdate('value', old);
  this._syncNativeSelect();
}

private _commitUserValue(next: string | string[]) {
  this._uncontrolledValue = next;
  this._syncNativeSelect();
  this.dispatchEvent(new CustomEvent('wc-select-change', {
    bubbles: true,
    composed: true,
    detail: {
      value: next,
      selectedValues: toArray(next),
      selectedOptions: this.selectedOptions,
    },
  }));
}
```

## Why It Matters

Property writes are downward data flow. Emitting events from host writes creates feedback loops in Solid, React, Vue, and form libraries. User-originated events should be the single state-up channel and should carry enough detail that wrappers do not need to read internal element state.

## Related Rules

- [4-1 Dispatch Composed Events](4-1-composed-events.md)
- [4-2 Event Naming Conventions](4-2-event-naming.md)
- [11-1 Controlled and Default APIs](11-1-controlled-default-apis.md)
