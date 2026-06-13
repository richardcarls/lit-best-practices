---
title: Dispatch Events for Directive Listeners in WebDriver Tests
impact: HIGH
impactDescription: Avoids false failures when WebDriver click shortcuts miss directive-installed listeners
tags: testing, webdriverio, directives, events
---

## Dispatch Events for Directive Listeners in WebDriver Tests

WebDriver element `.click()` shortcuts may not exercise listeners installed through a Lit
directive in the same way as a real browser event sequence. When a test specifically verifies
directive-installed `addEventListener` behavior, dispatch the intended event explicitly with
the required `bubbles`, `cancelable`, and `composed` flags.

Keep a separate end-to-end interaction test for real pointer behavior. Explicit dispatch is a
targeted test technique, not a substitute for all user-interaction testing.
