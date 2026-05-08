---
title: Prefer Context over Deep Property Threading
impact: MEDIUM
impactDescription: Threading props through intermediaries couples components that don't need the data
tags: context, props, architecture, coupling, prop-drilling
---

## Prefer Context over Deep Property Threading

When a property must travel through components that don't use it — only forward it — those intermediaries become falsely coupled to the data contract. Add `@lit/context` once the depth reaches 3 levels.

**Incorrect:**

```typescript
// 4-level chain: root → layout → sidebar → nav-item
// layout and sidebar only carry userId, never use it

@customElement('app-root')
export class AppRoot extends LitElement {
  @state() private _userId = '';
  render() {
    return html`<app-layout userId=${this._userId}></app-layout>`;
  }
}

@customElement('app-layout')
export class AppLayout extends LitElement {
  @property({ type: String }) userId = ''; // Not used here
  render() {
    return html`<app-sidebar userId=${this.userId}></app-sidebar>`;
  }
}

@customElement('app-sidebar')
export class AppSidebar extends LitElement {
  @property({ type: String }) userId = ''; // Not used here either
  render() {
    return html`<nav-item userId=${this.userId}></nav-item>`;
  }
}

@customElement('nav-item')
export class NavItem extends LitElement {
  @property({ type: String }) userId = ''; // Finally used here
}
```

**Correct:**

```typescript
// contexts/user-context.ts
export const userIdContext = createContext<string>('userId');

// Root provides
@customElement('app-root')
export class AppRoot extends LitElement {
  @provide({ context: userIdContext })
  @state()
  private _userId = '';
  render() {
    return html`<app-layout></app-layout>`;
  }
}

// Intermediaries have no awareness of userId
@customElement('app-layout')
export class AppLayout extends LitElement {
  render() { return html`<app-sidebar></app-sidebar>`; }
}

@customElement('app-sidebar')
export class AppSidebar extends LitElement {
  render() { return html`<nav-item></nav-item>`; }
}

// Consumer reads directly
@customElement('nav-item')
export class NavItem extends LitElement {
  @consume({ context: userIdContext, subscribe: true })
  private _userId!: string;
}
```

**When to use each pattern:**

| Depth | Consumer count | Recommendation |
|-------|---------------|----------------|
| 1–2 levels | Any | `@property` — explicit, testable, no package needed |
| 3+ levels | 1 leaf | Consider context; evaluate coupling cost |
| 3+ levels | 2+ leaves | Use context |
| Cross-tree (siblings, portals) | Any | Use context |

Props are the right default. Switch to context only when forwarding creates real coupling overhead — not preemptively.
