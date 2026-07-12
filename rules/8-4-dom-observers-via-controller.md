---
title: Wrap DOM Observers in Reactive Controllers
impact: MEDIUM
impactDescription: Inline observer setup lacks teardown symmetry and cannot be reused
tags: reactive-controllers, ResizeObserver, IntersectionObserver, MutationObserver, lifecycle
---

## Wrap DOM Observers in Reactive Controllers

`ResizeObserver`, `IntersectionObserver`, and `MutationObserver` all require explicit teardown.
Wrapping them in reactive controllers ties that teardown to the element's lifecycle automatically
and makes the observer reusable across components.

**Incorrect:**

```typescript
@customElement('lazy-image')
export class LazyImage extends LitElement {
  @property({ type: String }) src = '';
  @state() private _visible = false;
  private _observer?: IntersectionObserver;

  // Setup and teardown manually in each component that needs it
  firstUpdated() {
    this._observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) {
        this._visible = true;
        this._observer?.disconnect(); // Easy to forget
      }
    });
    this._observer.observe(this);
  }

  disconnectedCallback() {
    this._observer?.disconnect(); // Easy to forget
    super.disconnectedCallback();
  }
}
```

**Correct:**

```typescript
// controllers/intersection-controller.ts
import type { ReactiveController, ReactiveControllerHost } from 'lit';

export class IntersectionController implements ReactiveController {
  private _host: ReactiveControllerHost & Element;
  private _observer: IntersectionObserver;

  isIntersecting = false;

  constructor(
    host: ReactiveControllerHost & Element,
    private _options?: IntersectionObserverInit,
  ) {
    this._host = host;
    this._observer = new IntersectionObserver(([entry]) => {
      this.isIntersecting = entry.isIntersecting;
      this._host.requestUpdate();
    }, this._options);

    host.addController(this);
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
@customElement('lazy-image')
export class LazyImage extends LitElement {
  @property({ type: String }) src = '';
  private _intersection = new IntersectionController(this, { threshold: 0.1 });

  render() {
    const src = this._intersection.isIntersecting ? this.src : undefined;
    return html`<img src=${src ?? nothing} alt="">`;
  }
}
```

**Observer teardown cheat sheet:**

| Observer | Teardown method | Common mistake |
| ---------- | ---------------- | ---------------- |
| `ResizeObserver` | `observer.disconnect()` | Forgetting on `disconnectedCallback` |
| `IntersectionObserver` | `observer.disconnect()` | Not disconnecting one-shot observers after trigger |
| `MutationObserver` | `observer.disconnect()` | Missing cleanup on conditional observers |

**Combine with Task for data-on-visibility:**

```typescript
private _intersection = new IntersectionController(this);

private _dataTask = new Task(this, {
  task: async ([visible]) => visible ? fetchData() : null,
  args: () => [this._intersection.isIntersecting] as const,
});
```
