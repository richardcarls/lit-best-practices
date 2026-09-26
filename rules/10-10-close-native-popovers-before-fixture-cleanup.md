---
title: Close Native Popovers Before Fixture Cleanup
impact: HIGH
impactDescription: Prevents Firefox focus and active-item failures that appear only after a previous test left a native popover open
tags: testing, vitest, browser-mode, popover, dialog, focus, teardown
---

## Close Native Popovers Before Fixture Cleanup

A browser-mode test can fail a focus or active-item assertion in Firefox even though it passes
alone and the widget ends focused. Look at the preceding tests: if one left a native popover or
modal dialog open, the renderer's cleanup removes it while the next test is already setting up.

Some render helpers clean up the previous fixture at the start of the next test, not after the
current one. `vitest-browser-lit`, for example, registers its automatic `cleanup()` in
`beforeEach`.
Removing an open top-layer element closes it implicitly and runs focus transitions, and Firefox
can settle part of that asynchronously. A blur from the old fixture can then reach a composite
widget the new test has just focused, and its controller clears the active item: "menu has focus,
active marker is missing."

Close top-layer elements through the component's public, silent state API while they are still
connected, and await the render that calls `hidePopover()`:

**Incorrect (open popovers are left for the next test's cleanup to remove):**

```typescript
it('opens the menu on click', async () => {
  const el = await render(html`<wc-menu-button></wc-menu-button>`);
  await userEvent.click(el);
  expect(el.open).toBe(true);
});
```

**Correct (close through public state and await the update in `afterEach`):**

```typescript
afterEach(async () => {
  const openHosts = Array.from(
    document.querySelectorAll<WcMenuButton>('wc-menu-button'),
  ).filter((host) => host.open);

  for (const host of openHosts) {
    host.open = false;
  }

  await Promise.all(openHosts.map((host) => host.updateComplete));
});
```

Keep the hook suite-local unless the test infrastructure can express a safe generic top-layer
contract: a component's close path may also restore focus, sync ARIA, or release controllers,
which removing `:popover-open` nodes directly skips. Separately wait for an observable readiness
condition, such as a populated item list, before dispatching keyboard events, so an
initialization race is not mistaken for a teardown race.

The teardown mechanism was inferred from the renderer's cleanup order and a fix that held across
repeated Firefox runs, a Chromium run, and a 724-test Firefox project; no Firefox event trace was
captured. Do not change production focus logic until the failure still reproduces with explicit
top-layer cleanup.

Reference: [vitest-browser-lit](https://github.com/vitest-community/vitest-browser-lit)
