---
title: Use @lit/task for Async Data Fetching
impact: HIGH
impactDescription: Manual loading/error state management is error-prone and duplicated across components
tags: async, task, reactive-controllers, data-fetching, loading-state
---

## Use @lit/task for Async Data Fetching

The `Task` reactive controller from `@lit/task` manages the full async lifecycle (pending, complete,
and error states) as a single reactive unit. Manual `@state` flags for loading and error scatter
state and miss edge cases like race conditions.

**Incorrect:**

```typescript
@customElement('user-profile')
export class UserProfile extends LitElement {
  @property({ type: String }) userId = '';

  @state() private _user?: User;
  @state() private _loading = false;
  @state() private _error?: Error;

  // Manual effect tracking — easy to forget userId changes
  async connectedCallback() {
    super.connectedCallback();
    await this._fetchUser();
  }

  private async _fetchUser() {
    this._loading = true;
    this._error = undefined;
    try {
      const res = await fetch(`/api/users/${this.userId}`);
      this._user = await res.json();
    } catch (e) {
      this._error = e as Error;
    } finally {
      this._loading = false;
    }
  }

  render() {
    if (this._loading) return html`<p>Loading…</p>`;
    if (this._error) return html`<p>Error: ${this._error.message}</p>`;
    return html`<p>${this._user?.name}</p>`;
  }
}
```

**Correct:**

```typescript
import { Task } from '@lit/task';

@customElement('user-profile')
export class UserProfile extends LitElement {
  @property({ type: String }) userId = '';

  // Re-runs automatically when userId changes
  private _userTask = new Task(this, {
    task: async ([userId], { signal }) => {
      const res = await fetch(`/api/users/${userId}`, { signal });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json() as Promise<User>;
    },
    args: () => [this.userId] as const,
  });

  render() {
    return this._userTask.render({
      pending: () => html`<p>Loading…</p>`,
      complete: (user) => html`<p>${user.name}</p>`,
      error: (e) => html`<p>Error: ${(e as Error).message}</p>`,
    });
  }
}
```

**Task status API:**

```typescript
// Inspect status imperatively when needed
this._userTask.status   // TaskStatus.INITIAL | PENDING | COMPLETE | ERROR
this._userTask.value    // Result when COMPLETE, undefined otherwise
this._userTask.error    // Error when ERROR, undefined otherwise
```

**Abort signal:**

The `signal` parameter in the task function is an `AbortSignal` tied to the task lifecycle. Pass it
to `fetch` so in-flight requests are canceled when arguments change or the element disconnects;
preventing stale state from landing after a faster re-run completes.

**Installation:**

```bash
npm install @lit/task
```
