---
name: lit-best-practices
description: |
  Lit web components best practices for AI-assisted code generation, code review, refactoring, and debugging. Use when working in any Lit project — planning or designing components, generating new component code, updating or extending existing components, auditing for accessibility or performance, integrating async data, sharing state across components, or writing tests. 51 rules across 11 categories (component structure, rendering, styling, events, lifecycle, accessibility, performance, reactive controllers, context API, testing, custom element interop/API design) ranked by impact.
  TRIGGER when: planning or designing Lit web components; generating new Lit component code; updating or extending existing Lit components; reviewing or auditing Lit code for correctness, accessibility, or performance; debugging reactive property or lifecycle issues; writing tests for custom elements.
  SKIP: questions about non-Lit UI frameworks (React, Vue, Angular, Solid) with no Lit code involved; general HTML/CSS questions without web component context.
license: MIT
author: community
version: 1.3.0
allowed-tools:
  - Read
  - Grep
  - Glob
metadata:
  topics:
    - ai-agent-skill
    - llm-skill
    - lit
    - web-components
---

# Lit Web Components Best Practices

Best practices for building Lit web components, optimized for AI-assisted code generation and review.

## When to Use

Reference these guidelines when:

- Writing new Lit web components
- Implementing reactive properties and state
- Reviewing code for performance or accessibility issues
- Refactoring existing Lit components
- Optimizing rendering and update cycles

## Rule Categories

| Category | Rules | Focus |
|----------|-------|-------|
| 1. Component Structure | 5 rules | Properties, state, TypeScript, slots |
| 2. Rendering | 5 rules | Templates, directives, derived state |
| 3. Styling | 4 rules | Static styles, theming, CSS parts |
| 4. Events | 3 rules | Custom events, naming, cleanup |
| 5. Lifecycle | 6 rules | Callbacks, timing, async, SSR safety |
| 6. Accessibility | 4 rules | ARIA, focus, forms |
| 7. Performance | 4 rules | Updates, caching, lazy loading |
| 8. Reactive Controllers | 4 rules | Reusable behaviors, async tasks, observers |
| 9. Context API | 3 rules | Cross-component state, provider scope |
| 10. Testing | 8 rules | Setup, rendering, assertions, events, a11y |
| 11. Custom Element Interop/API Design | 5 rules | Controlled/default APIs, events, light DOM, rich data |

## Priority Levels

| Priority | Description | Action |
|----------|-------------|--------|
| **CRITICAL** | Major correctness or accessibility issues | Fix immediately |
| **HIGH** | Significant maintainability/performance impact | Address in current PR |
| **MEDIUM** | Best practice violations | Address when touching related code |
| **LOW** | Style preferences, micro-optimizations | Consider during refactoring |

## Rules Index

### 1. Component Structure
- `rules/1-1-use-decorators.md` - Use TypeScript Decorators (HIGH)
- `rules/1-2-separate-state.md` - Separate Public Properties from Internal State (HIGH)
- `rules/1-3-reflect-sparingly.md` - Reflect Properties Sparingly (MEDIUM)
- `rules/1-4-default-values.md` - Always Provide Default Values (HIGH)
- `rules/1-5-slot-composition.md` - Slot Composition Patterns (HIGH)

### 2. Rendering
- `rules/2-1-pure-render.md` - Keep render() Pure (CRITICAL)
- `rules/2-2-use-nothing.md` - Use nothing for Empty Content (MEDIUM)
- `rules/2-3-use-repeat.md` - Use repeat() for Keyed Lists (HIGH)
- `rules/2-4-use-cache.md` - Use cache() for Conditional Subtrees (MEDIUM)
- `rules/2-5-derived-state.md` - Compute Derived State in willUpdate() (HIGH)

### 3. Styling
- `rules/3-1-static-styles.md` - Always Use Static Styles (CRITICAL)
- `rules/3-2-host-styling.md` - Style the Host Element Properly (HIGH)
- `rules/3-3-css-custom-properties.md` - CSS Custom Properties for Theming (MEDIUM)
- `rules/3-4-css-parts.md` - CSS Parts for Deep Styling (MEDIUM)

### 4. Events
- `rules/4-1-composed-events.md` - Dispatch Composed Events (CRITICAL)
- `rules/4-2-event-naming.md` - Event Naming Conventions (MEDIUM)
- `rules/4-3-cleanup-listeners.md` - Clean Up Event Listeners (HIGH)

### 5. Lifecycle
- `rules/5-1-super-call-order.md` - Correct super() Call Order (CRITICAL)
- `rules/5-2-first-updated.md` - Use firstUpdated for DOM Operations (HIGH)
- `rules/5-3-will-update.md` - Use willUpdate for Derived State (HIGH)
- `rules/5-4-update-complete.md` - Async Operations with updateComplete (MEDIUM)
- `rules/5-5-ssr-safe-construction.md` - SSR-Safe Construction (MEDIUM)
- `rules/5-6-defer-slotchange-mutations.md` - Defer DOM Mutations in Slotchange Handlers (CRITICAL)

### 6. Accessibility
- `rules/6-1-delegates-focus.md` - delegatesFocus for Interactive Components (HIGH)
- `rules/6-2-aria-attributes.md` - ARIA for Custom Interactive Components (CRITICAL)
- `rules/6-3-form-associated.md` - Form-Associated Custom Elements (HIGH)
- `rules/6-4-popover-focus-management.md` - Popover Focus Return Management (HIGH)

### 7. Performance
- `rules/7-1-has-changed.md` - Custom hasChanged for Complex Types (HIGH)
- `rules/7-2-batch-updates.md` - Batch Property Updates (MEDIUM)
- `rules/7-3-lazy-loading.md` - Lazy Load Heavy Dependencies (HIGH)
- `rules/7-4-memoization.md` - Memoize Expensive Computations (MEDIUM)

### 8. Reactive Controllers
- `rules/8-1-use-reactive-controllers.md` - Use Reactive Controllers for Reusable Behaviors (HIGH)
- `rules/8-2-implement-controller-interface.md` - Implement the ReactiveController Interface Correctly (HIGH)
- `rules/8-3-use-task-for-async.md` - Use @lit/task for Async Data Fetching (HIGH)
- `rules/8-4-dom-observers-via-controller.md` - Wrap DOM Observers in Reactive Controllers (MEDIUM)

### 9. Context API
- `rules/9-1-use-context-for-shared-state.md` - Use @lit/context for Cross-Component State (HIGH)
- `rules/9-2-scope-context-providers.md` - Scope Context Providers at the Right Level (MEDIUM)
- `rules/9-3-prefer-context-over-prop-threading.md` - Prefer Context over Deep Property Threading (MEDIUM)

### 10. Testing
- `rules/10-1-configure-web-test-runner.md` - Configure @web/test-runner with @open-wc/testing (CRITICAL)
- `rules/10-2-use-fixture-for-rendering.md` - Use fixture() for Component Instantiation (HIGH)
- `rules/10-3-await-update-complete.md` - Await updateComplete Before DOM Assertions (HIGH)
- `rules/10-4-query-shadow-dom.md` - Query Shadow DOM Elements Correctly in Tests (HIGH)
- `rules/10-5-test-custom-events.md` - Test Custom Events with oneEvent() (HIGH)
- `rules/10-6-test-slot-rendering.md` - Test Slot Content Rendering (MEDIUM)
- `rules/10-7-test-controllers-in-isolation.md` - Test Reactive Controllers Without a Host Element (MEDIUM)
- `rules/10-8-test-accessibility.md` - Test Accessibility with axe-core (MEDIUM)

### 11. Custom Element Interop/API Design
- `rules/11-1-controlled-default-apis.md` - Controlled and Default APIs (HIGH)
- `rules/11-2-silent-host-writes.md` - Silent Host Writes (HIGH)
- `rules/11-3-light-dom-progressive-enhancement.md` - Light DOM Progressive Enhancement (HIGH)
- `rules/11-4-rich-data-properties.md` - Rich Data Properties (HIGH)
- `rules/11-5-author-attributes-and-upgrade.md` - Author Attributes and Upgrade Safety (HIGH)
## Task-Based Rule Selection

### Writing New Components
- `1-1-use-decorators.md` — property declarations + tsconfig `useDefineForClassFields: false`
- `1-2-separate-state.md` — public vs internal state; Set/Map mutation trap
- `1-5-slot-composition.md` — distributing light DOM
- `3-1-static-styles.md` — styling approach
- `4-1-composed-events.md` — event configuration
- `5-5-ssr-safe-construction.md` — avoid browser globals in constructor
- `5-6-defer-slotchange-mutations.md` — safe slotchange handler pattern
- `11-1-controlled-default-apis.md` — framework-safe value/open APIs
- `11-3-light-dom-progressive-enhancement.md` — declarative fallback/native source sync

### Sharing State Across Components
- `9-1-use-context-for-shared-state.md` — context basics
- `9-2-scope-context-providers.md` — provider placement
- `9-3-prefer-context-over-prop-threading.md` — when to switch from props

### Async Data Fetching
- `8-3-use-task-for-async.md` — Task controller
- `8-1-use-reactive-controllers.md` — controller pattern

### Code Review
Check for violations of CRITICAL rules:
- `2-1-pure-render.md` — side effects in render()
- `3-1-static-styles.md` — inline styles in templates
- `4-1-composed-events.md` — events not composed
- `5-1-super-call-order.md` — wrong super() order
- `5-6-defer-slotchange-mutations.md` — synchronous DOM mutations in slotchange handlers
- `6-2-aria-attributes.md` — missing accessibility
- `10-1-configure-web-test-runner.md` — test setup correctness

### Performance Optimization
- `2-3-use-repeat.md` — list rendering
- `2-5-derived-state.md` — expensive computations
- `7-1-has-changed.md` — update optimization
- `7-3-lazy-loading.md` — code splitting
- `8-4-dom-observers-via-controller.md` — observer lifecycle

### Accessibility Audit
- `6-1-delegates-focus.md` — focus handling
- `6-2-aria-attributes.md` — ARIA implementation
- `6-3-form-associated.md` — form integration
- `10-8-test-accessibility.md` — automated axe-core testing

### Testing
- `10-1-configure-web-test-runner.md` — Web Test Runner/open-wc or Vitest browser mode with Playwright setup (CRITICAL)
- `10-2-use-fixture-for-rendering.md` — component instantiation
- `10-3-await-update-complete.md` — async assertion timing + microtask flush for slotchange
- `10-4-query-shadow-dom.md` — querying rendered output
- `10-5-test-custom-events.md` — event assertions + synthetic event `composed` flag
- `10-7-test-controllers-in-isolation.md` — unit testing controllers
- `6-4-popover-focus-management.md` — keyboard/focus tests for popover-based components

## Quick Reference

### Essential Imports

```typescript
// Core
import { LitElement, html, css, nothing } from 'lit';
import { customElement, property, state, query } from 'lit/decorators.js';

// Common Directives
import { repeat } from 'lit/directives/repeat.js';
import { cache } from 'lit/directives/cache.js';
import { classMap } from 'lit/directives/class-map.js';
import { until } from 'lit/directives/until.js';

// Reactive Controllers
import type { ReactiveController, ReactiveControllerHost } from 'lit';
import { Task } from '@lit/task';

// Context API
import { createContext, provide, consume } from '@lit/context';

// Testing
import { fixture, expect, html, oneEvent } from '@open-wc/testing';
// Or use Vitest browser mode with @vitest/browser-playwright for Chrome/Firefox.
```

### Component Skeleton

```typescript
@customElement('my-component')
export class MyComponent extends LitElement {
  static styles = css`
    :host { display: block; }
    :host([hidden]) { display: none; }
  `;

  @property({ type: String }) value = '';
  @property({ type: Boolean, reflect: true }) disabled = false;
  @state() private _internal = '';

  render() {
    return html`<slot></slot>`;
  }
}
```

## Resources

- [Lit Documentation](https://lit.dev/docs/)
- [Open Web Components](https://open-wc.org/)
- [Lion Web Components](https://github.com/ing-bank/lion)
- [web.dev Custom Elements Best Practices](https://web.dev/articles/custom-elements-best-practices)
