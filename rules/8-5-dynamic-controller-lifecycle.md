---
title: Dynamic ReactiveController Add/Remove Lifecycle
impact: HIGH
impactDescription: addController on an already-connected host fires hostConnected synchronously; removeController does not fire hostDisconnected, so listeners leak unless detached manually first
tags: reactive-controllers, lifecycle, addController, removeController
---

## Dynamic ReactiveController Add/Remove Lifecycle

### `addController` on a connected host fires `hostConnected` synchronously

When `host.addController(controller)` is called while the host is already connected to
the DOM (that is, from `updated()`, `firstUpdated()`, or any post-connect callback), Lit
**immediately calls `controller.hostConnected()`** synchronously inside `addController`.

This means any initial state the controller sets (listeners attached, callbacks fired,
initial evaluation run) happens before control returns to the caller. You can rely on
the controller's initial `onScroll` / `onChange` / evaluation callback having already
fired by the time `addController` returns.

```ts
// controller.hostConnected() fires here, synchronously
this._scrollObs = new ScrollObserverController(this, {
  target: () => this._findScrollTarget(),
  onScroll: (scrollTop) => this.toggleAttribute('below', scrollTop < threshold),
});
// By this line, onScroll has already been called with the current scrollTop
```

### `removeController` does NOT call `hostDisconnected`

`host.removeController(controller)` just removes the controller from the host's internal
Set. It does **not** call `controller.hostDisconnected()` or perform any cleanup.

If the controller has attached event listeners or holds other resources, call the cleanup
path explicitly before removing:

```ts
// WRONG — listener stays attached after removeController
this.removeController(this._scrollObs);

// CORRECT — detach listener first, then remove from host
this._scrollObs.setOptions({ disabled: true }); // triggers internal detach
this.removeController(this._scrollObs);
this._scrollObs = undefined;
```

## When this bites you

Dynamic controller management; adding a controller from `updated()` in response to a
property change, and later removing it when the property is unset. The immediate
`hostConnected` fire is a **feature**: initial state is correct without pre-seeding
attributes. The missing `hostDisconnected` is a **pitfall**: scroll/resize/mutation
listeners leak if you skip the explicit cleanup step.
