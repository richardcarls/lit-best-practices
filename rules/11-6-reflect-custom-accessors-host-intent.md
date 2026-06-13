---
title: Preserve Host Intent with Reflected Custom Accessors
impact: HIGH
impactDescription: Prevents Lit's reflection cycle from clobbering author-provided attributes
tags: properties, reflection, accessors, upgrade
---

## Preserve Host Intent with Reflected Custom Accessors

When a reflected Lit property uses a custom getter/setter, keep the host-requested value in a
dedicated field and return it immediately from the getter. If the getter instead derives only
from internal state that has not settled yet, Lit can read the initial value during its update
cycle and remove or rewrite the author's attribute.

```typescript
private _requestedDisabled = false;

@property({ type: Boolean, reflect: true })
get disabled(): boolean {
  return this._requestedDisabled;
}

set disabled(value: boolean) {
  const old = this._requestedDisabled;
  this._requestedDisabled = value;
  this.requestUpdate("disabled", old);
}
```

Keep effective internal state separate when it can differ from host intent, and test initial
markup, property writes, and the first completed update.
