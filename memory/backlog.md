# Backlog

## Reconcile README with the implemented configuration

The README was compared with the reviewed main source during memory
reconstruction. It still describes an older environment and check surface.

When repository documentation work is authorized, compare README against an
explicit current baseline and address these verified discrepancies together:

- Replace the old emacs31-pgtk/emacs31-gtk3 implementation attributes with the
  generic emacs-pgtk/emacs-gtk selection actually used by the flake.
- Describe the four project check families: startup smoke, package availability,
  Elisp byte compilation and grammar runtime. Include the separate treefmt
  formatting check and preserve each check's limited validation scope.
- Replace the older scope-only override description with scope.overrideAttrs
  and scope.executablePackages responsibilities and package-directory assertions.
- Remove obsolete superchat details and review the illustrated source/test tree
  against the current helper, Lisp and exporter layout.
- Attribute old successful build results to their historical baseline or replace
  them only after authorized current validation; do not relabel them as fresh.

Use the git-maintenance README workflow when undertaking the update.
This entry authorizes no project modification, build, dependency update or
network action. The README remains unchanged; no new build result is available.
