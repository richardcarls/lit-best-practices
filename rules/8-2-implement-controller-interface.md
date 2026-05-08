---
title: Implement the ReactiveController Interface Correctly
impact: HIGH
impactDescription: Missing addController() call silently disconnects all lifecycle hooks
tags: reactive-controllers, ReactiveController, lifecycle, addController
---

## Implement the ReactiveController Interface Correctly

A controller that never calls `host.addController(this)` will not participate in the host's lifecycle — `hostConnected` and `hostDisconnected` are never called, subscriptions are never set up, and state never triggers re-renders.

**Incorrect:**

```typescript
export class ClockController {
  private _host: ReactiveControllerHost;
  private _timer?: ReturnType<typeof setInterval>;

  time = new Date();

  constructor(host: ReactiveControllerHost) {
    this._host = host;
    // Missing: host.addController(this)
    // hostConnected() will never be called
  }

  hostConnected() {
    this._timer = setInterval(() => {
      this.time = new Date();
      this._host.requestUpdate();
    }, 1000);
  }

  hostDisconnected() {
    clearInterval(this._timer);
  }
}
```

**Correct:**

```typescript
import type { ReactiveController, ReactiveControllerHost } from 'lit';

export class ClockController implements ReactiveController {
  private _host: ReactiveControllerHost;
  private _timer?: ReturnType<typeof setInterval>;

  time = new Date();

  constructor(host: ReactiveControllerHost) {
    this._host = host;
    host.addController(this); // Registers all lifecycle callbacks with the host
  }

  hostConnected() {
    this._timer = setInterval(() => {
      this.time = new Date();
      this._host.requestUpdate();
    }, 1000);
  }

  hostDisconnected() {
    clearInterval(this._timer);
  }
}
```

**Full ReactiveController interface:**

```typescript
interface ReactiveController {
  hostConnected?(): void;      // Element added to document
  hostDisconnected?(): void;   // Element removed from document
  hostUpdate?(): void;         // Called before each render
  hostUpdated?(): void;        // Called after each render
}
```

All methods are optional — implement only what the controller needs.

**Lifecycle hook use cases:**

| Hook | Use for |
|------|---------|
| `hostConnected` | Start subscriptions, observers, timers |
| `hostDisconnected` | Clean up all resources |
| `hostUpdate` | Read host properties before render |
| `hostUpdated` | Read rendered DOM after update |

Always `implements ReactiveController` to get compile-time verification that the interface is satisfied.
