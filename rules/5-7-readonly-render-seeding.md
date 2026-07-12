---
title: Seed initial render from firstUpdated for read-only elements
impact: HIGH
impactDescription: Read-only elements that receive no slotchange event stay blank without an explicit firstUpdated render seed
tags: lifecycle, firstUpdated, render, readonly, slotchange
---

## Seed initial render from firstUpdated for read-only elements

Property setters are called by frameworks **before** the element connects to the DOM. A
`_scheduleRender()` guard on internal state set in `firstUpdated` silently no-ops all
pre-connect calls:

```typescript
private async _performRender(): Promise<void> {
  if (!this._document) return;  // _document set in firstUpdated — exits early here
  ...
}
```

For editable elements that accept a slotted `<textarea>`, `slotchange` fires **after**
`firstUpdated`, providing a secondary trigger that re-runs `_scheduleRender()` with
`_document` now available.

For **read-only** elements with no slotted child, `slotchange` either never fires or
returns early; and the element stays empty even though all properties were set correctly.

**Fix:** Call `_scheduleRender()` at the end of `firstUpdated()`, after all internal setup
is complete:

```typescript
override firstUpdated(): void {
  const editorEl = this._getEditorEl();
  if (editorEl) {
    this._document = new V2Document(editorEl as HTMLDivElement);
    this._bindEditorEvents(editorEl);
  }
  this._resizeObserver = new ResizeObserver(() => { ... });
  this._resizeObserver.observe(this);

  // Seed initial render for read-only elements — no slotchange fires for them.
  // For editable elements this fires one extra RAF before the slotchange render;
  // the duplicate is harmless.
  this._scheduleRender();
}
```

**Why this surprises agents:** The symptom (element appears empty) looks exactly like a
consumer-side wiring bug. The real cause is a component-internal lifecycle gap: the
secondary trigger that works for editable elements does not exist for read-only ones.

Diagnosis: read `_scheduleRender` / `_performRender` and trace all callers to confirm the
read-only path has none that fire after `firstUpdated`.
