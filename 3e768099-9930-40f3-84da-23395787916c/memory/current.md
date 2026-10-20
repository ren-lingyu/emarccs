# Org workflow ownership discovery

## Scope and registry foundation
Recovered from the July registry/include and ownership discussions. Source
horizons were surveyed; no original exact commit association or new runtime
acceptance is asserted. org-roam-include and organization registries replace
legacy flat settings while keeping navigation and an explicit include-mode key.

## Citation dependency boundary
The organization provider uses Citar selection, lookup and formatting APIs,
not Citar-Org-Roam as its implementation dependency. External organization
depends on Org and Org-roam. Nevertheless retain Citar-Org-Roam at this stage:
removing it before workflow validation conflicts with the owner's stability goal.
Consolidate Citar, Citar-Embark, Citar-Org-Roam and provider registration in the
organization workflow module; remove the former roam-citar entry and update
requires together.

An unbound org-roam-directory was caused by configuring Citar after Org alone.
Order it after both Org and Org-roam. Static restructuring changes execution
timing; it is not proof that every lazy-load path now works.

## Distribute aggregate responsibilities
Move TeX export setup to TeX, preview configuration to preview, timestamp and
database post queries to Org-roam, and save/publication behavior to publishing.
Use org-directory as the runtime root rather than a personal aggregate alias.
The intermediate package-loading aggregate moves to the shared entry; its
later removal and Docker preview removal are separate decisions.
Localize org-element loading in the functions that need it.

## Next action
Apply ownership-based symbol names, then distinguish owner smoke reports from
a proposed test suite. Do not describe static inspection as runtime acceptance.
