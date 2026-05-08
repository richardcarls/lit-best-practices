---
title: Use Reactive Controllers for Reusable Behaviors
impact: HIGH
impactDescription: Ad-hoc lifecycle code in each component cannot be shared or tested in isolation
tags: reactive-controllers, reusability, lifecycle, composition
---

## Use Reactive Controllers for Reusable Behaviors

Reactive controllers encapsulate stateful logic that participates in a host element's update lifecycle. Extract behaviors that would otherwise be duplicated across components into controllers.

**Incorrect:**

```typescript
// Same resize-tracking logic copy-pasted into every component that needs it
@customElement('card-layout')
export class CardLayout extends LitElement {
  @state() private _width = 0;
  private _observer?: ResizeObserver;

  connectedCallback() {
    super.connectedCallback();
    this._observer = new ResizeObserver(([entry]) => {
      this._width = entry.contentRect.width;
    });
    this._observer.observe(this);
  }

  disconnectedCallback() {
    this._observer?.disconnect();
    super.disconnectedCallback();
  }
}

// And again in another component...
@customElement('data-table')
export class DataTable extends LitElement {
  @state() private _width = 0;
  private _observer?: ResizeObserver;
  // ... same 15 lines of boilerplate
}
```

**Correct:**

```typescript
// controllers/resize-controller.ts
import type { ReactiveControllerHost } from 'lit';

export class ResizeController {
  private _host: ReactiveControllerHost & Element;
  private _observer: ResizeObserver;

  width = 0;
  height = 0;

  constructor(host: ReactiveControllerHost & Element) {
    this._host = host;
    this._observer = new ResizeObserver(([entry]) => {
      this.width = entry.contentRect.width;
      this.height = entry.contentRect.height;
      this._host.requestUpdate();
    });

    host.addController(this); // Required — registers lifecycle hooks
  }

  hostConnected() {
    this._observer.observe(this._host);
  }

  hostDisconnected() {
    this._observer.disconnect();
  }
}
```

```typescript
// Any component that needs resize tracking
@customElement('card-layout')
export class CardLayout extends LitElement {
  private _resize = new ResizeController(this);

  render() {
    return html`<p>Width: ${this._resize.width}px</p>`;
  }
}
```

**When to extract a controller:**

| Signal | Recommendation |
|--------|----------------|
| Same `connectedCallback` / `disconnectedCallback` code in 2+ components | Extract to controller |
| Logic that holds its own state and updates the host | Extract to controller |
| Browser API that needs explicit teardown | Extract to controller |
| One-time setup with no reactive state | Keep inline in component |
