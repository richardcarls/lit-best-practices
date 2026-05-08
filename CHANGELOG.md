# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-05-08

### Added

**Category 8: Reactive Controllers (4 rules)**

- `8-1-use-reactive-controllers.md` (HIGH) — Extract repeated lifecycle code into
  reusable reactive controllers; shows the before/after of ad-hoc `connectedCallback`
  vs. an encapsulated `ResizeController`
- `8-2-implement-controller-interface.md` (HIGH) — Correctly implement
  `ReactiveController`; the silent failure caused by omitting `host.addController(this)`
  in the constructor
- `8-3-use-task-for-async.md` (HIGH) — Replace manual loading/error `@state` flags
  with `@lit/task`; covers abort signal for race-condition prevention
- `8-4-dom-observers-via-controller.md` (MEDIUM) — Wrap `ResizeObserver`,
  `IntersectionObserver`, and `MutationObserver` in controllers for automatic
  connect/disconnect lifecycle management

**Category 9: Context API (3 rules)**

- `9-1-use-context-for-shared-state.md` (HIGH) — `@lit/context` basics: `createContext`,
  `@provide`, `@consume`; explains why context identity is reference-based
- `9-2-scope-context-providers.md` (MEDIUM) — Place providers at the lowest common
  ancestor, not always at the root; shows testing benefit of tight scoping
- `9-3-prefer-context-over-prop-threading.md` (MEDIUM) — Decision table for when to
  switch from property threading to context (3+ levels, cross-tree)

**Category 10: Testing (8 rules)**

- `10-1-configure-web-test-runner.md` (CRITICAL) — Minimal `web-test-runner.config.mjs`,
  required devDependencies, and a symptom-to-cause diagnosis table
- `10-2-use-fixture-for-rendering.md` (HIGH) — `fixture()` vs `document.createElement`;
  why createElement leaves shadow DOM empty
- `10-3-await-update-complete.md` (HIGH) — Await `updateComplete` after property
  mutations before DOM assertions; one await covers multiple batched property changes
- `10-4-query-shadow-dom.md` (HIGH) — `el.shadowRoot!.querySelector` vs `el.querySelector`;
  shadow vs light DOM query targets
- `10-5-test-custom-events.md` (HIGH) — `oneEvent()` from `@open-wc/testing`; why
  hand-written Promise wrappers have a race condition
- `10-6-test-slot-rendering.md` (MEDIUM) — Assert on light DOM children and
  `slot.assignedElements()`, not shadow DOM queries
- `10-7-test-controllers-in-isolation.md` (MEDIUM) — Mock `ReactiveControllerHost`
  pattern for unit-testing controller logic without rendering a component
- `10-8-test-accessibility.md` (MEDIUM) — `expect(el).to.be.accessible()` via axe-core;
  which states to test and how to scope rule runs

**Additions to existing categories**

- `1-5-slot-composition.md` (HIGH) — Slot API (`assignedElements`, `slotchange`),
  named slots, `::slotted()` CSS; common mistake of querying shadow DOM for slotted content
- `5-5-ssr-safe-construction.md` (MEDIUM) — Never access `document`, `window`, or DOM APIs
  in the constructor; lifecycle table showing which callbacks are safe in SSR environments

### Changed

- `SKILL.md` — Updated rule count (27 → 44), added 3 new category sections to the rules
  index, added Task-Based Rule Selection section, extended Essential Imports with controller
  and context imports
- `AGENTS.md` — Added new task categories (Sharing State, Async Data Fetching, Testing),
  added `addController` and test-assertion mistakes to the Common Mistakes table
- `README.md` — Updated category table (7 → 10 categories, 27 → 44 rules), added new
  Key Patterns sections, updated install command to `richardcarls/lit-best-practices`
- `metadata.json` — Bumped version to `1.1.0`, updated abstract and keyword list,
  corrected repository URL to `richardcarls/lit-best-practices`

## [1.0.0] - 2026-01-21

Initial release by [@artmsilva](https://github.com/artmsilva).

27 rules across 7 categories: Component Structure, Rendering, Styling, Events, Lifecycle,
Accessibility, Performance.
