---
title: Scope Context Providers at the Right Level
impact: MEDIUM
impactDescription: Providers placed too high create unnecessary global coupling; too low they don't reach all consumers
tags: context, provider, architecture, scope, coupling
---

## Scope Context Providers at the Right Level

A context provider should live at the **lowest common ancestor** that spans all its consumers.
Placing every provider at the document root makes state globally mutable from anywhere, makes
testing harder, and means every test must set up the entire application context.

**Incorrect:**

```typescript
// Everything at the root, even if only used in one subtree
@customElement('app-root')
export class AppRoot extends LitElement {
  @provide({ context: themeContext }) theme: Theme = 'light';
  @provide({ context: userContext }) user: User | null = null;
  @provide({ context: cartContext }) cart: CartItem[] = [];       // used only in /checkout
  @provide({ context: editorContext }) editorState = new EditorState(); // used only in /editor
}
```

**Correct:**

```typescript
// App-wide state lives at the root
@customElement('app-root')
export class AppRoot extends LitElement {
  @provide({ context: themeContext }) theme: Theme = 'light';
  @provide({ context: userContext }) user: User | null = null;

  render() {
    return html`<app-router></app-router>`;
  }
}

// Feature-scoped state lives at the feature root
@customElement('checkout-page')
export class CheckoutPage extends LitElement {
  @provide({ context: cartContext }) cart: CartItem[] = [];

  render() {
    return html`
      <cart-summary></cart-summary>
      <payment-form></payment-form>
    `;
  }
}

@customElement('editor-page')
export class EditorPage extends LitElement {
  @provide({ context: editorContext }) editorState = new EditorState();

  render() {
    return html`
      <editor-toolbar></editor-toolbar>
      <editor-canvas></editor-canvas>
    `;
  }
}
```

**Provider scope decision:**

| State used in… | Provider should live at… |
| ---------------- | -------------------------- |
| Every page / global UI | App root |
| One route or feature | That route's root component |
| A single compound widget | The widget's container element |
| One component only | `@state()`; no context needed |

**Testing benefit of tight scoping:**

Feature-scoped providers let you test a feature in isolation by rendering just its root element
rather than a full application shell:

```typescript
const el = await fixture(html`<checkout-page></checkout-page>`);
// cartContext is provided automatically — no app-root wrapper needed
```
