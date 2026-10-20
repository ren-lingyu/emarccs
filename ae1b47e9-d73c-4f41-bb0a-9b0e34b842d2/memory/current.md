# Dual-entry packaging discovery

## Source boundary
This source covers the long July 7-16 session from explicit-package experiments
through main handoff, including nested Twist investigations. Entire substantive
horizons were surveyed; settings-only later events add no implementation.
Exact original main-commit provenance is not established. All validation below
is attributed historical evidence, not a build or runtime run now.

## Adopted architecture
Keep straight bootstrap separate from shared behavior; a locked explicit Nix
package set supplies the same shared configuration. Reject alwaysEnsure and
blanket :ensure rewrites: installed packages are not automatic feature activation.
Local recipes outrank MELPA then ELPA git; copied regular recipe entries avoid
the reproduced symlink-farm discovery failure. Explicit mirrors handle selected
ELPA aliases. Org's fork recipe generates org-version metadata.

Emacs 31 advice preserves store early-init, real user early-init and shared-before-
user-init ordering; --no-init-file skips wrapper config. Do not reset
user-emacs-directory. Generated citar autoloads need cl-lib before their
cl-defsubst expansion. Flake-owned paths/features are rendered through small
Elisp adapters; the temporary string-context workaround was removed after an
upstream fix. GTK/PGTK outputs share version locks and expose per-variant apps.

AUCTeX needs explicit manual builds and native Git/Perl/TeX tools, including a
ChangeLog fix outside Git checkouts and no shell collision with the info output.
Use package-specific writable HOME fixes; Elisp dependency metadata remains
distinct from executable/native inputs.

## Reported validation and qualification
Availability 201 pass/4 skip, enablement 19/5 and module config 87/7 reported no
failures. API probes had 9 passes/9 known drifts and no unexpected drift.
Org-roam fixture checks had 13 passes/4 skips; live moves/deletes were deferred.
Preview probes had 23 passes/0 failures plus owner-confirmed GUI overlays.
Three GUI startup modes supported ordering/skip behavior. Startup/availability
flake smoke checks are narrower than full interactive workflow acceptance.

Standalone Texinfo, app metadata and regular-file registry reproductions
informed upstream reports. The autoload problem was narrowed to a specific
package rather than treated as a universal Twist defect. External issue state
is not rechecked or closed here.

## Pure bootstrap and handoff
A fresh pure GUI appeared blank while synchronous bootstrap downloaded from raw
GitHub. Copying only bootstrap.el was insufficient because straight.el itself
was missing. The owner copied the full straight repository and reported package
installation/build progress. This is not automated fresh-install acceptance.
The result was handed to main; the nested Twist checkout is not a deployed
project directory. Documentation should describe tracked project paths rather
than scratch, backup or nested experimental trees.

## Completion
Source conclusions are distilled. Formal integration should adopt the completed
dual-entry environment with these limits, retaining this final source state as
explanatory context rather than implying every experiment exists in main.
