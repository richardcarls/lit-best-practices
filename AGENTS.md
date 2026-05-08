# Lit Web Components Best Practices - Agent Guide

> **Note:** This document provides high-level guidance for AI agents working with Lit components. Detailed rules with code examples are in the `rules/` directory.

## How to Use This Skill

1. **Read SKILL.md first** for the rule index and quick reference
1. **Load specific rules as needed** based on the task at hand
1. **Prioritize by impact** - CRITICAL and HIGH rules should always be followed

## Rule Selection by Task

### Writing New Components

- `1-1-use-decorators.md` - Property declarations
- `1-2-separate-state.md` - Public vs internal state
- `1-5-slot-composition.md` - Distributing light DOM through slots
- `3-1-static-styles.md` - Styling approach
- `4-1-composed-events.md` - Event configuration
- `5-5-ssr-safe-construction.md` - Avoid browser globals in constructor

### Reviewing Components

Check for violations of CRITICAL rules:

- `2-1-pure-render.md` - Side effects in render()
- `3-1-static-styles.md` - Inline styles in templates
- `4-1-composed-events.md` - Events not composed
- `5-1-super-call-order.md` - Wrong super() order
- `6-2-aria-attributes.md` - Missing accessibility
- `10-1-configure-web-test-runner.md` - Test setup correctness

### Sharing State Across Components

- `9-1-use-context-for-shared-state.md` - Context basics
- `9-2-scope-context-providers.md` - Provider placement
- `9-3-prefer-context-over-prop-threading.md` - When to switch from props

### Async Data Fetching

- `8-3-use-task-for-async.md` - Task reactive controller
- `8-1-use-reactive-controllers.md` - Controller pattern

### Performance Optimization

- `2-3-use-repeat.md` - List rendering
- `2-5-derived-state.md` - Expensive computations
- `7-1-has-changed.md` - Update optimization
- `7-3-lazy-loading.md` - Code splitting
- `8-4-dom-observers-via-controller.md` - Observer lifecycle management

### Accessibility Audit

- `6-1-delegates-focus.md` - Focus handling
- `6-2-aria-attributes.md` - ARIA implementation
- `6-3-form-associated.md` - Form integration
- `10-8-test-accessibility.md` - Automated axe-core testing

### Testing

- `10-1-configure-web-test-runner.md` - Test runner setup (CRITICAL)
- `10-2-use-fixture-for-rendering.md` - Component instantiation
- `10-3-await-update-complete.md` - Async assertion timing
- `10-4-query-shadow-dom.md` - Querying rendered output
- `10-5-test-custom-events.md` - Event assertions
- `10-7-test-controllers-in-isolation.md` - Unit testing controllers

## Critical Patterns to Always Follow

### 1. Static Styles Only

```typescript
// ✓ Always
static styles = css`...`;

// ✗ Never
render() {
  return html`<style>...</style>...`;
}
```

### 2. Composed Events

```typescript
// ✓ Always
this.dispatchEvent(new CustomEvent('change', {
  bubbles: true,
  composed: true,
  detail: { value }
}));
```

### 3. Pure render()

```typescript
// ✓ Only return templates
render() {
  return html`...`;
}

// ✗ No side effects
render() {
  this.count++; // Bad
  console.log(); // Bad
  return html`...`;
}
```

### 4. Correct Lifecycle Order

```typescript
connectedCallback() {
  super.connectedCallback(); // First
  // Your code
}

disconnectedCallback() {
  // Your code
  super.disconnectedCallback(); // Last
}
```

### 5. State Separation

```typescript
// Public API
@property({ type: String }) value = '';

// Internal only
@state() private _computed = '';
```

### 6. Register Controllers in Constructor

```typescript
constructor(host: ReactiveControllerHost) {
  this._host = host;
  host.addController(this); // Required — omitting this silently disables all lifecycle hooks
}
```

## Common Mistakes to Catch

| Mistake | Rule | Fix |
| --- | --- | --- |
| Inline `<style>` in template | 3-1 | Use `static styles` |
| Event without `composed: true` | 4-1 | Add to CustomEvent options |
| Side effects in render() | 2-1 | Move to updated() or willUpdate() |
| No default property values | 1-4 | Add `= ''` or appropriate default |
| Reflecting complex types | 1-3 | Remove `reflect: true` for objects/arrays |
| super() in wrong position | 5-1 | First in connectedCallback, last in disconnectedCallback |
| DOM access in connectedCallback | 5-2 | Move to firstUpdated() |
| Setting state in updated() | 5-3 | Use willUpdate() for derived state |
| Missing keyboard handlers | 6-2 | Add @keydown with Space/Enter handling |
| map() for dynamic lists | 2-3 | Use repeat() directive with keys |
| Missing `addController(this)` | 8-2 | Call in controller constructor |
| Assert before `updateComplete` | 10-3 | `await el.updateComplete` after property set |
| `el.querySelector` for shadow content | 10-4 | Use `el.shadowRoot!.querySelector` |

## File Structure

```text
lit-best-practices/
├── SKILL.md          # Index, quick reference, when to use
├── AGENTS.md         # This file - agent guidance
├── README.md         # Human documentation
└── rules/
    ├── 1-1-use-decorators.md
    ├── 1-2-separate-state.md
    ├── ...
    └── 10-8-test-accessibility.md
```

## Rule File Format

Each rule file contains:

- **Frontmatter** with title, impact, tags
- **Problem description**
- **Incorrect code example**
- **Correct code example**
- **Explanation of why**

Load rules by reading the specific file when that topic is relevant to the current task.
