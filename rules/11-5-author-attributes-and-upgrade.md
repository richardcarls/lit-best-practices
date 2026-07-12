---
title: Author Attributes and Upgrade Safety
priority: HIGH
category: Custom Element Interop/API Design
---

# Author Attributes and Upgrade Safety

## Rule

Handle properties that authors or frameworks set before custom-element upgrade, and avoid overriding
author-provided global attributes such as `role`, `tabindex`, `aria-*`, `class`, and `style`.

## Incorrect

```ts
connectedCallback() {
  super.connectedCallback();
  this.tabIndex = 0;
  this.setAttribute('role', 'button');
  this.value = '';
}
```

## Correct

```ts
connectedCallback() {
  super.connectedCallback();
  this._capturePreUpgradeProperty('value');

  if (!this.hasAttribute('role')) {
    this.setAttribute('role', 'button');
  }

  if (!this.hasAttribute('tabindex')) {
    this.tabIndex = 0;
  }
}

private _capturePreUpgradeProperty(name: 'value') {
  if (!Object.prototype.hasOwnProperty.call(this, name)) return;

  const value = this[name];
  delete this[name];
  this[name] = value;
}
```

## Why It Matters

Frameworks often assign properties before the element class has upgraded. Custom elements must
preserve those values instead of replacing them with class defaults. Authors also need final control
over global attributes that affect styling, semantics, and focus behavior.

## Related Rules

- [3-2 Style the Host Element Properly](3-2-host-styling.md)
- [6-2 ARIA for Custom Interactive Components](6-2-aria-attributes.md)
- [11-2 Silent Host Writes](11-2-silent-host-writes.md)
