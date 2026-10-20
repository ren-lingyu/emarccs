# Org workflow ownership discovery

## Source boundary
This source joins July 25 registry/include work, July 29 ownership/naming and
the subsequent ERT proposal. Entire substantive horizons were surveyed.
No original exact main commit provenance is inferred, and no checks are run now.

## Adopted ownership and integration
Organization registries and org-roam-include replace flat legacy settings.
The citation provider uses Citar directly; retain Citar-Org-Roam at this source
stage until separate workflow evidence justifies removal. Citar configuration
must wait for both Org and Org-roam to avoid an unbound roam directory.
The workflow module owns citation selection, adapters and registry setup.

Dismantle the personal integration aggregate: TeX owns export tools, preview
owns preview setup, Org-roam owns timestamps and post queries, and publishing
owns save/publication behavior. Use the shared Org root rather than a personal
alias. Temporary shared package loading was later removed as redundant.
Docker preview removal is distinct from the ownership split.
Require org-element locally where used rather than globally through Org.

## Naming policy
Use provided-feature-name for public symbols and provided-feature--name for
private ones. Ownership follows domain and primary API rather than call site;
cross-file consumers require a public interface. Do not rename underscore
lexical locals as part of public namespacing.
The source applied names to seven modules, explicitly excluding blog publishing.
Helpful helpers, theme commands and Org date APIs have different owners from
private organization provider helpers.

## Verification and test proposals
Static diff checks passed and the owner reported manual smoke checks with no
blockers. This is not complete runtime acceptance. The ERT session proposed
coverage for custom buffer logic, publishing, date handling, theme behavior and
link descriptions, including missing-description/nil cases. It did not create
or run that suite. Later publishing extraction changes which old targets still
belong in this repository; do not turn the proposal into an unreviewed backlog.
An ignored TODO note was requested to remain outside tracked project content;
neither it nor raw conversations are archived here.

## Completion
Formal integration should adopt applicable workflow ownership and namespace
decisions while preserving the distinction between source-stage retained
packages, later repository changes, owner smoke checks and unimplemented tests.
