# Lit Web Components Best Practices

A reusable AI agent skill containing comprehensive best practices for building Lit web components,
optimized for code generation, review, and refactoring.

## Overview

This skill contains 52 rules across 11 categories, prioritized by impact to guide automated
refactoring and code generation:

| Category | Rules | Focus |
| --- | --- | --- |
| Component Structure | 5 | Properties, state, TypeScript patterns, slots |
| Rendering | 6 | Templates, directives, performance |
| Styling | 4 | Static styles, theming, CSS parts |
| Events | 3 | Custom events, naming, cleanup |
| Lifecycle | 6 | Callbacks, timing, async patterns, SSR safety |
| Accessibility | 4 | ARIA, focus, form association, popovers |
| Performance | 4 | Updates, caching, lazy loading |
| Reactive Controllers | 4 | Reusable behaviors, async tasks, DOM observers |
| Context API | 3 | Cross-component state, provider scope |
| Testing | 8 | Setup, rendering, assertions, events, a11y |
| Custom Element Interop/API Design | 5 | Controlled/default APIs, light DOM fallback, rich properties |

## Installation

```bash
npx skills add richardcarls/lit-best-practices
```

## Structure

```text
lit-best-practices/
├── SKILL.md
├── AGENTS.md
├── README.md
└── rules/
    ├── 1-1-use-decorators.md
    ├── 2-1-pure-render.md
    ├── 11-1-controlled-default-apis.md
    └── ...
```

The rules are split into individual files so agents can load only the rules relevant to the current
task.

## Usage

The skill activates for tasks involving Lit web components, custom elements, shadow DOM, reactive
properties, framework interop, or web component testing.

## Key Patterns Covered

### Component Structure

- TypeScript decorators for properties
- Separating public API (`@property`) from internal state (`@state`)
- Primitive reflection guidelines and property-only rich data
- Default values and type safety
- Named and default slot composition

### Events

- Composed, bubbling custom events for shadow DOM
- Component-specific event names such as `wc-select-change`
- Rich detail payloads for user interaction events
- Silent host-set property writes for downward data flow

### Lifecycle and Slots

- Correct callback ordering
- Safe DOM access timing
- SSR-safe construction
- Synchronous slot reads with deferred mutation, focus, and observer setup

### Accessibility

- `delegatesFocus` for interactive components
- ARIA roles and states where the accessible flat tree can see slotted children
- Keyboard interaction and focus return
- Form-associated custom elements
- Respect for author-provided `role`, `tabindex`, and `aria-*`

### Custom Element Interop/API Design

- `value`/`defaultValue` and `open`/`defaultOpen` APIs
- No events from host-set property updates
- Light-DOM native controls as declarative sources and fallback form controls
- Programmatic rich data via properties, not attributes
- Pre-upgrade property capture and author-owned global attributes

### Testing

- Vitest browser mode with Playwright for current Chrome/Firefox projects
- Web Test Runner/open-wc as an accepted library testing stack
- `fixture()` for connected, rendered component instantiation
- Awaiting `updateComplete` and slot microtasks before assertions
- Cross-browser timing tests for property-before-connect, slot replacement, silent host writes, and
  native fallback sync

## Reference Resources

- [Lit Documentation](https://lit.dev/docs/)
- [Open Web Components](https://open-wc.org/)
- [web.dev Custom Elements Best Practices](https://web.dev/articles/custom-elements-best-practices)

## Contributing

1. Rules include clear incorrect/correct examples
1. Impact level is justified
1. TypeScript examples are properly typed
1. Accessibility implications are considered
1. New examples stay generic and use hypothetical `<wc-*>` components

## License

MIT
