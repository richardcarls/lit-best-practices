---
title: Use @lit/context for Cross-Component State
impact: HIGH
impactDescription: Property threading across 3+ component levels tightly couples unrelated components
tags: context, shared-state, dependency-injection, lit-context, provider, consumer
---

## Use @lit/context for Cross-Component State

`@lit/context` implements the context protocol for Lit — a type-safe, event-based mechanism for sharing state down a component tree without threading props through every intermediate layer.

**Incorrect:**

```typescript
// Root must thread theme down through every intermediate layer
@customElement('app-root')
export class AppRoot extends LitElement {
  @state() private _theme = 'light';

  render() {
    return html`
      <app-layout theme=${this._theme}>
        <app-sidebar theme=${this._theme}></app-sidebar>
        <app-content theme=${this._theme}></app-content>
      </app-layout>
    `;
  }
}

// Intermediate component carries theme only to pass it through
@customElement('app-layout')
export class AppLayout extends LitElement {
  @property({ type: String }) theme = '';
  render() {
    return html`<slot></slot>`; // theme unused here, just passed to children
  }
}
```

**Correct:**

```typescript
// contexts/theme-context.ts
import { createContext } from '@lit/context';

export type Theme = 'light' | 'dark';
export const themeContext = createContext<Theme>('theme');
```

```typescript
// Provider: owns the state, provides it to descendants
import { provide } from '@lit/context';
import { themeContext, type Theme } from './contexts/theme-context.js';

@customElement('app-root')
export class AppRoot extends LitElement {
  @provide({ context: themeContext })
  @state()
  private _theme: Theme = 'light';

  private _toggleTheme() {
    this._theme = this._theme === 'light' ? 'dark' : 'light';
  }

  render() {
    return html`
      <button @click=${this._toggleTheme}>Toggle</button>
      <app-layout></app-layout>
    `;
  }
}
```

```typescript
// Consumer: reads context directly, no prop needed
import { consume } from '@lit/context';
import { themeContext, type Theme } from './contexts/theme-context.js';

@customElement('theme-icon')
export class ThemeIcon extends LitElement {
  @consume({ context: themeContext, subscribe: true })
  private _theme!: Theme;

  render() {
    return html`<span>${this._theme === 'dark' ? '🌙' : '☀️'}</span>`;
  }
}
```

**Key options:**

| Option | Effect |
|--------|--------|
| `subscribe: true` | Consumer re-renders when context value changes (required for reactive updates) |
| `subscribe: false` (default) | Consumer reads the value once at connect time |

**Installation:**

```bash
npm install @lit/context
```

Contexts are identified by the object reference passed to `createContext`, not by string equality — always import the context object from a shared module rather than recreating it.
