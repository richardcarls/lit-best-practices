# Lit Web Components Best Practices

A reusable AI agent skill containing comprehensive best practices for building Lit web components, optimized for code generation, review, and refactoring.

## Overview

This skill contains 44 rules across 10 categories, prioritized by impact to guide automated refactoring and code generation:

| Category | Rules | Focus |
| --- | --- | --- |
| Component Structure | 5 | Properties, state, TypeScript patterns, slots |
| Rendering | 5 | Templates, directives, performance |
| Styling | 4 | Static styles, theming, CSS parts |
| Events | 3 | Custom events, naming, cleanup |
| Lifecycle | 5 | Callbacks, timing, async patterns, SSR safety |
| Accessibility | 3 | ARIA, focus, form association |
| Performance | 4 | Updates, caching, lazy loading |
| Reactive Controllers | 4 | Reusable behaviors, async tasks, DOM observers |
| Context API | 3 | Cross-component state, provider scope |
| Testing | 8 | Setup, rendering, assertions, events, a11y |

## Installation

### AI Agent Platforms

```bash
npx skills add richardcarls/lit-best-practices
```

### Manual Installation

Add the skill folder to your project knowledge or paste `SKILL.md` into your agent prompt.

## Structure

```
lit-best-practices/
├── SKILL.md          # Lightweight index + quick reference
├── AGENTS.md         # High-level guidance for AI agents
├── README.md         # This file
└── rules/            # Individual rule files (loaded on-demand)
    ├── 1-1-use-decorators.md
    ├── 2-1-pure-render.md
    ├── 6-2-aria-attributes.md
    └── ...
```

The rules are split into individual files so agents can load only the rules relevant to the current task, saving context.

## Usage

The skill automatically activates when an AI agent detects tasks involving:

- Lit web components
- Custom elements
- Shadow DOM
- Reactive properties
- Web component testing

### Example Prompts

```
"Create a Lit component for a dropdown menu with keyboard navigation"
"Review this Lit component for accessibility issues"
"Refactor this component to follow Lit best practices"
"Add form association to this custom input component"
```

## Priority Levels

Rules are categorized by impact:

| Priority | Description | Action |
|----------|-------------|--------|
| **CRITICAL** | Major performance or correctness issues | Fix immediately |
| **HIGH** | Significant impact on maintainability/performance | Address in current PR |
| **MEDIUM** | Best practice violations | Address when touching related code |
| **LOW** | Style preferences and micro-optimizations | Consider during refactoring |

## Key Patterns Covered

### Component Structure

- TypeScript decorators for properties
- Separating public API (`@property`) from internal state (`@state`)
- Property reflection guidelines
- Default values and type safety
- Named and default slot composition

### Rendering

- Pure `render()` methods
- Using `nothing` for conditional content
- `repeat()` directive for keyed lists
- `cache()` directive for view switching
- Derived state in `willUpdate()`

### Styling

- Static styles (never inline `<style>`)
- `:host` element styling patterns
- CSS custom properties for theming
- CSS parts for deep customization

### Events

- Composed events for shadow DOM
- Naming conventions
- Event listener cleanup

### Lifecycle

- Correct `super` call ordering
- `firstUpdated` for DOM operations
- `willUpdate` vs `updated` usage
- Async patterns with `updateComplete`
- SSR-safe construction (no browser globals in constructor)

### Accessibility

- `delegatesFocus` for interactive components
- ARIA roles and states
- Keyboard interaction
- Form-associated custom elements

### Performance

- Custom `hasChanged` functions
- Property update batching
- Lazy loading
- Memoization patterns

### Reactive Controllers

- Creating reusable reactive behaviors
- Implementing the `ReactiveController` interface correctly
- `@lit/task` for async data fetching with abort signals
- Wrapping `ResizeObserver`, `IntersectionObserver`, `MutationObserver` in controllers

### Context API

- `@lit/context` for cross-component state sharing
- Scoping providers at the correct ancestor level
- When to use context vs. property threading

### Testing

- `@web/test-runner` + `@open-wc/testing` configuration
- `fixture()` for connected, rendered component instantiation
- Awaiting `updateComplete` before DOM assertions
- Querying shadow DOM correctly
- Asserting custom events with `oneEvent()`
- Testing slot content and reactive controllers in isolation
- Automated accessibility testing with axe-core

## Reference Resources

- [Lit Documentation](https://lit.dev/docs/)
- [Open Web Components](https://open-wc.org/)
- [Lion Web Components](https://github.com/ing-bank/lion)
- [Shoelace](https://shoelace.style/)
- [Adobe Spectrum Web Components](https://github.com/adobe/spectrum-web-components)
- [web.dev Custom Elements Best Practices](https://web.dev/articles/custom-elements-best-practices)

## Contributing

Contributions welcome! Please ensure:

1. Rules include clear incorrect/correct examples
2. Impact level is justified
3. TypeScript examples are properly typed
4. Accessibility implications are considered

## License

MIT
