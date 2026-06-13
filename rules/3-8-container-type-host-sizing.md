---
title: Container Queries Change Host Sizing
impact: HIGH
impactDescription: Prevents container-query setup from silently breaking intrinsic host sizing
tags: styling, container-queries, host, sizing
---

## Container Queries Change Host Sizing

Putting `container-type: inline-size` on `:host` makes the custom element the query container,
but size containment also changes how the host contributes intrinsic size. On `inline` and
`inline-flex` hosts, content-driven width can collapse or stop behaving as expected.

Use host containment only when the component contract owns an externally constrained width.
Otherwise put containment on an internal wrapper with a known available width.

Test the component both in constrained layouts and where it is expected to size to content.
