---
title: Test Reactive Controllers Without a Host Element
impact: MEDIUM
impactDescription: Rendering a full component to test controller logic couples unit tests to component rendering
tags: testing, reactive-controllers, unit-testing, mock-host, isolation
---

## Test Reactive Controllers Without a Host Element

Reactive controllers implement logic that can be tested independently by providing a minimal mock host. This avoids rendering a full component just to exercise controller behavior.

**Incorrect:**

```typescript
// Tests controller behavior through a real component —
// brittle because component rendering details bleed into controller tests
it('ClockController updates the time', async () => {
  const el = await fixture<MyClock>(html`<my-clock></my-clock>`);
  await el.updateComplete;

  await new Promise((resolve) => setTimeout(resolve, 1100));
  await el.updateComplete;

  // Asserting on rendered text — breaks if component template changes
  const display = el.shadowRoot!.querySelector('.time')!;
  expect(display.textContent).to.not.equal('');
});
```

**Correct:**

```typescript
import type { ReactiveControllerHost } from 'lit';
import { ClockController } from '../src/controllers/clock-controller.js';

// Minimal host mock — satisfies ReactiveControllerHost without rendering
class MockHost implements ReactiveControllerHost {
  updateCount = 0;

  addController() { /* noop — controller manages itself */ }
  removeController() {}
  requestUpdate() { this.updateCount++; }

  get updateComplete(): Promise<boolean> {
    return Promise.resolve(true);
  }
}

describe('ClockController', () => {
  it('calls requestUpdate after each tick', async () => {
    const host = new MockHost();
    const clock = new ClockController(host, { intervalMs: 100 });

    clock.hostConnected();

    await new Promise((resolve) => setTimeout(resolve, 350));

    expect(host.updateCount).to.be.greaterThanOrEqual(3);
    clock.hostDisconnected();
  });

  it('exposes the current time', () => {
    const host = new MockHost();
    const clock = new ClockController(host);
    clock.hostConnected();

    const before = Date.now();
    expect(clock.time.getTime()).to.be.closeTo(before, 100);

    clock.hostDisconnected();
  });

  it('stops updating after hostDisconnected', async () => {
    const host = new MockHost();
    const clock = new ClockController(host, { intervalMs: 50 });
    clock.hostConnected();
    clock.hostDisconnected();

    const countAfterDisconnect = host.updateCount;
    await new Promise((resolve) => setTimeout(resolve, 200));

    expect(host.updateCount).to.equal(countAfterDisconnect);
  });
});
```

**MockHost pattern:**

```typescript
// Reusable across controller test suites
class MockHost implements ReactiveControllerHost {
  updateCount = 0;
  controllers: ReactiveController[] = [];

  addController(c: ReactiveController) { this.controllers.push(c); }
  removeController(c: ReactiveController) {
    this.controllers = this.controllers.filter((x) => x !== c);
  }
  requestUpdate() { this.updateCount++; }

  get updateComplete() { return Promise.resolve(true); }
}
```

Isolating controllers this way makes the test suite faster (no browser rendering cycle), more focused, and resilient to component template changes.
