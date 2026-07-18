---
id: 5-9
title: Guard imperative DOM calls in property setters with isConnected
category: Lifecycle
priority: HIGH
status: draft
tags: [lit, isConnected, attributes, timing, showModal, InvalidStateError]
description: Lit processes observed attribute setters during template cloning before the element is connected; imperative DOM calls like showModal() throw InvalidStateError at that point
---

## The Invariant

When Lit upgrades a custom element that already has attributes in HTML (or when a
template clones an element with attributes), the property setters for those attributes
run while the element is still disconnected from the document (`isConnected === false`).

Browser APIs that require a connected element; `showModal()`, `show()` on `<dialog>`,
`requestFullscreen()`, etc.; throw `InvalidStateError` if called at this point.

## What Went Wrong

`rc-dialog` had a `defaultOpen` setter that called `_applyOpen(true)` which called
`dlg.showModal()`. When a test rendered `<rc-dialog default-open>`, Lit processed
the attribute before connecting the element to the DOM. The `<dialog>` child was
visible inside the host (Lit clones the template), but neither the host nor the child
was connected, so `showModal()` threw immediately:

```text
InvalidStateError: Dialog element is not connected
```

The bug was silent in production because users typically add `default-open` to already-
mounted elements, or the timing window is too narrow to hit. Tests that render clean
DOM catch it reliably.

## The Fix

Guard any property setter that may call a browser API requiring connection:

```ts
set defaultOpen(value: boolean) {
  this._defaultOpen = value;

  // Guard: Lit runs setters during template cloning before isConnected.
  // firstUpdated / _setupDialog handles the initial open state on connect.
  if (this._controlledOpen === undefined && value && this.isConnected) {
    this._applyOpen(true, true, this.modal);
  }

  this.requestUpdate('defaultOpen', this._defaultOpen);
}
```

The connected lifecycle (`firstUpdated`, `connectedCallback`, a `MutationObserver`
callback from `connectedCallback`) already handles the initial state separately.
The eager setter path is only needed for _dynamic_ attribute changes after the element
is already in the DOM.

## General Pattern

When a property setter calls any browser API that requires a connected element:

1. Add `&& this.isConnected` to the setter guard.
1. Let `firstUpdated()` or `connectedCallback()` handle initial state independently.
1. Avoid duplication by checking `_setupDialog` / equivalent already reads the property.

**Don't** move the `isConnected` check into `_applyOpen` itself; that silently swallows
intended programmatic calls and makes the bug harder to find.
