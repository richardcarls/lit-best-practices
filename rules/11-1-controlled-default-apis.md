---
title: Controlled and Default APIs
priority: HIGH
category: Custom Element Interop/API Design
---

# Controlled and Default APIs

## Rule

Expose canonical controlled and uncontrolled properties for user-editable state. Use
`value`/`defaultValue` for form-like components and `open`/`defaultOpen` for disclosure components.

## Incorrect

```ts
@customElement('wc-select')
export class WcSelect extends LitElement {
  @property({ type: Array }) selectedValues: string[] = [];

  setSelected(values: string[]) {
    this.selectedValues = values;
    this.dispatchEvent(new CustomEvent('wc-select-change'));
  }
}
```

## Correct

```ts
@customElement('wc-select')
export class WcSelect extends LitElement {
  @property({ attribute: false }) value?: string | string[];
  @property({ attribute: false }) defaultValue?: string | string[];
  @state() private _uncontrolledValue: string | string[] = '';

  get selectedValues(): string[] {
    return toArray(this.value ?? this._uncontrolledValue);
  }

  private get _currentValue() {
    return this.value ?? this._uncontrolledValue;
  }
}
```

```ts
@customElement('wc-dialog')
export class WcDialog extends LitElement {
  @property({ type: Boolean }) open?: boolean;
  @property({ type: Boolean }) defaultOpen = false;
}
```

## Why It Matters

Frameworks can pass properties before connection, during render, or after a slot update. A
predictable `value`/`defaultValue` or `open`/`defaultOpen` contract makes those writes declarative
and avoids wrapper-level timers, imperative setup calls, and hidden state duplication.

## Related Rules

- [11-2 Silent Host Writes](11-2-silent-host-writes.md)
- [11-3 light DOM Progressive Enhancement](11-3-light-dom-progressive-enhancement.md)
- [1-4 Always Provide Default Values](1-4-default-values.md)
