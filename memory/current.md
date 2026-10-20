# Current memory

The represented state introduces normalized ext-block semantics with separate
source and export namespaces. Source AST nodes retain native Org types and raw
properties while gaining validated semantic properties. Backend lowering and
parameter export are separate responsibilities.

Native Org-roam forward links replace consult-org-roam. Date helpers are scoped
with package configuration and save-hook organization has evolved. Read
`architecture.md` for the full project state and evidence limits.

Next recover package-directory assertions, overrideAttrs contracts and
package-local executable aggregation, then reconcile the current main tip.
No export/runtime suite is rerun; repository inspection does not prove the
original session used these exact snapshots. See `reconstruction.md`.
