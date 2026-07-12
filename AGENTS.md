# Lit Web Components Best Practices - Agent Guide

> **Note:** This document provides high-level guidance for AI agents working with Lit components.
  Detailed rules with code examples are in the `rules/` directory.

## How to Use This Skill

1. Read `SKILL.md` first for the rule index and quick reference.
1. Load specific rules as needed based on the task.
1. Prioritize CRITICAL and HIGH rules during implementation and review.

## Rule Selection by Task

### Writing New Components

- `1-1-use-decorators.md` - Property declarations
- `1-2-separate-state.md` - Public vs internal state
- `1-5-slot-composition.md` - Distributing light DOM through slots
- `3-1-static-styles.md` - Styling approach
- `4-1-composed-events.md` - Event configuration
- `5-5-ssr-safe-construction.md` - Avoid browser globals in constructor
- `11-1-controlled-default-apis.md` - Framework-safe controlled/uncontrolled APIs
- `11-5-author-attributes-and-upgrade.md` - Pre-upgrade and author attribute safety

### Reviewing Components

Check for violations of CRITICAL and HIGH rules:

- `2-1-pure-render.md` - Side effects in render()
- `2-6-render-owned-geometry.md` - External geometry writes overwritten by Lit renders
- `3-1-static-styles.md` - Inline styles in templates
- `4-1-composed-events.md` - Events not composed
- `5-1-super-call-order.md` - Wrong super() order
- `5-6-defer-slotchange-mutations.md` - Slot timing and framework reentrancy
- `6-2-aria-attributes.md` - Missing or misplaced accessibility semantics
- `10-1-configure-web-test-runner.md` - Browser test setup correctness
- `11-2-silent-host-writes.md` - Events emitted from downward data flow
- `11-4-rich-data-properties.md` - Object/array data reflected to attributes

### Framework Interop and Progressive Enhancement

- `11-1-controlled-default-apis.md` - `value`/`defaultValue`, `open`/`defaultOpen`
- `11-2-silent-host-writes.md` - User-originated events only
- `11-3-light-dom-progressive-enhancement.md` - Native fallback and form sync
- `11-4-rich-data-properties.md` - Property-only rich data
- `11-5-author-attributes-and-upgrade.md` - Pre-upgrade property capture

### Testing

- `10-1-configure-web-test-runner.md` - Web Test Runner/open-wc or Vitest browser mode with Playwright
- `10-2-use-fixture-for-rendering.md` - Component instantiation
- `10-3-await-update-complete.md` - Async assertion timing and cross-browser timing cases
- `10-5-test-custom-events.md` - Event assertions
- `10-8-test-accessibility.md` - Automated axe-core testing

## Critical Patterns to Always Follow

### Static Styles Only

```typescript
static styles = css`...`;
```

### Composed Events for User Interaction

```typescript
this.dispatchEvent(new CustomEvent('wc-select-change', {
  bubbles: true,
  composed: true,
  detail: { value, selectedValues },
}));
```

### Silent Host Writes

```typescript
set value(next: string | string[] | undefined) {
  const old = this._value;
  this._value = next;
  this.requestUpdate('value', old);
  this._syncNativeControl();
}
```

### Host Styling

```typescript
static styles = css`
  :host { display: block; }
  :host([hidden]) { display: none; }
`;
```

## Common Mistakes to Catch

| Mistake | Rule | Fix |
| --- | --- | --- |
| Inline `<style>` in template | 3-1 | Use `static styles` |
| Event without `composed: true` | 4-1 | Add `bubbles: true` and `composed: true` |
| Side effects in render() | 2-1 | Move to lifecycle methods or event handlers |
| Reflecting complex types | 1-3, 11-4 | Use property-only rich data |
| Host property write dispatches change event | 11-2 | Dispatch only for user/native/internal state-up changes |
| Slotted native fallback ignored | 11-3 | Read and synchronize light-DOM controls |
| Component overwrites author `role` or `tabindex` | 11-5, 6-2 | Set defaults only when absent |
| Synchronous slotchange focus/mutation | 5-6 | Read synchronously, defer mutation with `queueMicrotask` |
| Assert before `updateComplete` | 10-3 | Await Lit updates and needed slot microtasks |

## File Structure

```text
lit-best-practices/
├── SKILL.md
├── AGENTS.md
├── README.md
└── rules/
    ├── 1-1-use-decorators.md
    ├── ...
    └── 11-5-author-attributes-and-upgrade.md
```

## Rule File Format

Each rule file contains frontmatter, a problem statement, incorrect/correct examples, why-it-matters
guidance, and related-rule links when useful.
