---
title: SSR-Safe Construction
impact: MEDIUM
impactDescription: Accessing browser globals in the constructor crashes server-side rendering
tags: ssr, constructor, lifecycle, document, window, lit-labs-ssr
---

## SSR-Safe Construction

The constructor runs in every environment — including Node.js during server-side rendering with `@lit-labs/ssr`. `document`, `window`, `navigator`, and other browser globals do not exist there.

**Incorrect:**

```typescript
@customElement('my-widget')
export class MyWidget extends LitElement {
  private _mq: MediaQueryList;
  private _observer: ResizeObserver;

  constructor() {
    super();
    // Crashes under SSR — document doesn't exist
    this._mq = window.matchMedia('(prefers-color-scheme: dark)');
    this._observer = new ResizeObserver(this._onResize);
    document.addEventListener('click', this._onDocClick);
  }
}
```

**Correct:**

```typescript
@customElement('my-widget')
export class MyWidget extends LitElement {
  private _mq?: MediaQueryList;
  private _observer?: ResizeObserver;

  connectedCallback() {
    super.connectedCallback();
    // Browser globals are safe here — element is in a live document
    this._mq = window.matchMedia('(prefers-color-scheme: dark)');
    this._mq.addEventListener('change', this._onSchemeChange);
    document.addEventListener('click', this._onDocClick);
  }

  firstUpdated() {
    // DOM-dependent setup goes here, after first render
    this._observer = new ResizeObserver(this._onResize);
    this._observer.observe(this);
  }

  disconnectedCallback() {
    this._mq?.removeEventListener('change', this._onSchemeChange);
    document.removeEventListener('click', this._onDocClick);
    this._observer?.disconnect();
    super.disconnectedCallback();
  }
}
```

**When to use each lifecycle callback:**

| Callback | Browser APIs safe? | Shadow DOM ready? | Use for |
|----------|--------------------|-------------------|---------|
| `constructor` | No | No | Initialize primitive properties only |
| `connectedCallback` | Yes | No | Media queries, document listeners, non-DOM setup |
| `firstUpdated` | Yes | Yes | DOM observers, focus, measurements |

**What is safe in the constructor:**

```typescript
constructor() {
  super();
  // Safe: primitive state initialization
  this._count = 0;
  this._items = [];
  this._label = 'default';
}
```

Avoid any call that transitively reaches `document`, `window`, `localStorage`, `navigator`, or `HTMLElement` APIs in the constructor.
