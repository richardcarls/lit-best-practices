---
id: 5-8
title: lit-updated-before-first-updated
category: Lifecycle
priority: HIGH
status: draft
tags: [lit, lifecycle, updated, firstUpdated, timing]
description: Lit calls updated() before firstUpdated() on the first cycle; skip/guard flags set inside firstUpdated() are consumed by the next real update, not the intended spurious first one
---

In Lit's first update cycle the order is: `update()` → `updated()` → `firstUpdated()`. Any flag
intended to suppress a spurious `updated()` call on the first cycle must be initialized in the
**class field declaration**, not inside `firstUpdated()`. A flag set inside `firstUpdated()` will
always miss the first `updated()` and be consumed by the very next user-triggered update instead.

**Pattern that breaks:**

```ts
private _skipFirst = false;  // starts false

override firstUpdated() {
  // ... initial content setup ...
  this._skipFirst = true;  // TOO LATE — first updated() already ran with _skipFirst=false
}

override updated(changed) {
  if (changed.has('someMode')) {
    if (this._skipFirst) { this._skipFirst = false; return; }  // skips the WRONG call
    this._switchMode();  // first real user click is dropped
  }
}
```

**Patterns that work:**

Option A; gate on "has init completed?":

```ts
private _initDone = false;

override firstUpdated() {
  // ... initial content setup ...
  this._initDone = true;
}

override updated(changed) {
  if (changed.has('someMode')) {
    if (!this._initDone) return;  // correctly skips pre-init updates
    this._switchMode();
  }
}
```

Option B; initialize the skip flag `true` so the first `updated()` consumes it:

```ts
private _skipFirstMode = true;  // true from the start

override updated(changed) {
  if (changed.has('someMode')) {
    if (this._skipFirstMode) { this._skipFirstMode = false; return; }
    this._switchMode();
  }
}
```

Option B is compact but hides intent; Option A is clearer when `firstUpdated()` already exists to do
setup work.

**Why this matters:** The bug manifests as a silently dropped first user interaction. Because
`updated()` only fires when a reactive property actually changes, the skipped call can be the very
first meaningful action the user takes.
