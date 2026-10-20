# Dual-entry packaging discovery

## Scope and foundation
This is the long July packaging source, including nested Twist experiments.
Exact main commit provenance is not reconstructed. Reported tests are source
evidence, not checks run now. Shared configuration should serve both straight
and explicit Nix package selection; alwaysEnsure was rejected for fetching
built-ins. Use locked explicit seeds and dependency closure, not per-package
flake inputs or automatic activation of installed packages.

## Adapter findings
Register local recipes centrally and keep native tools separate from Elisp
packageRequires. laas needs math-symbol-lists declared; company-auctex and
superchat perform build-time operations that need writable HOME, so override
them narrowly rather than changing all packages.
AUCTeX's generic Texinfo scan includes subordinate todo content and fails on
unknown macros; placeholder outputs are a temporary workaround, not the final
manual-build policy.

## Historical functional probes
The session reports package availability 201 pass/4 skip, enablement 19/5,
module configuration 87/7, all with zero failures. API probes found 9 passes
and 9 known drifts, with no unexpected drift; this is not compatibility of
every API. Org-roam fixture/database probes reported 13 passes/4 skips;
moving/deleting live notes remained deferred.
Org LaTeX preview probes reported 23 passes with no failures and owner-confirmed
GUI overlays. Require org-latex-preview explicitly instead of assuming Org
loads it. These probes have narrower scope than complete startup acceptance.

## Open work
Finish configured-wrapper startup, generated autoload requirements and GUI
ordering. Preserve fixture and skip limits when adopting the reported results.
