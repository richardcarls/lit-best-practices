---
title: Configure @web/test-runner with @open-wc/testing
impact: CRITICAL
impactDescription: Missing setup causes tests to pass while components silently fail to render or update
tags: testing, web-test-runner, open-wc, configuration, setup
---

## Configure @web/test-runner with @open-wc/testing

`@web/test-runner` runs tests in a real browser, which is the correct environment for custom elements. `@open-wc/testing` extends Chai with DOM-aware assertions and provides the `fixture()` helper. Without the right configuration, tests may pass while the component is broken.

**Incorrect:**

```javascript
// web-test-runner.config.mjs — Missing critical options
export default {
  files: 'src/**/*.test.js',
};
```

```typescript
// Missing @open-wc/testing — no fixture(), no DOM assertions
import { assert } from 'chai';
import '../src/my-element.js';

it('renders', () => {
  const el = document.createElement('my-element');
  document.body.appendChild(el);
  assert.isTrue(el.shadowRoot !== null); // No cleanup, no update wait
});
```

**Correct:**

```javascript
// web-test-runner.config.mjs
import { playwrightLauncher } from '@web/test-runner-playwright';

export default {
  files: 'src/**/*.test.ts',
  nodeResolve: true,         // Resolves npm package imports
  browsers: [
    playwrightLauncher({ product: 'chromium' }),
  ],
};
```

```typescript
// src/my-element.test.ts
import { fixture, expect, html } from '@open-wc/testing';
import '../src/my-element.js';

describe('MyElement', () => {
  it('renders', async () => {
    const el = await fixture<MyElement>(html`<my-element></my-element>`);
    await expect(el).shadowDom.to.equalSnapshot();
  });
});
```

**Required devDependencies:**

```json
{
  "devDependencies": {
    "@web/test-runner": "^0.19.0",
    "@web/test-runner-playwright": "^0.11.0",
    "@open-wc/testing": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
```

**package.json scripts:**

```json
{
  "scripts": {
    "test": "wtr",
    "test:watch": "wtr --watch"
  }
}
```

**Symptom diagnosis:**

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `customElements.get(...)` returns undefined | Component file not imported in test | Add `import '../src/my-element.js'` |
| `el.shadowRoot` is null | Component hasn't rendered yet | `await fixture()` waits for first update |
| Properties set but DOM not updated | Missing `await el.updateComplete` | Await before assertion (see rule 10-3) |
| `expect(...).to.equalSnapshot()` not found | Missing `@open-wc/testing` import | Import from `'@open-wc/testing'` not `'chai'` |
| Tests pass in CI but fail locally | Browser binary not installed | Run `npx playwright install chromium` |
