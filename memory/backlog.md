# Backlog

## Candidate regression coverage: custom-package command autoloads

The earlier Org-TeXmacs issue established two distinct failure modes: trivialBuild
installed sources without ELPA descriptors/autoloads, and a narrowed files recipe
omitted ox-texmacs.el even after activation worked. The committed migration uses
melpaBuild with explicit MELPA defaults and includes the Scheme worker.
Existing startup-smoke tests Citar/Consult/Org activation and library availability
checks locate dependencies; no maintained test directly verifies the three
Org-TeXmacs frontend commands are autoloaded from the installed package.
Consider a bounded batch regression check of frontend library presence and
command/autoload availability without eager require of ox-texmacs or invoking
TeXmacs/export. This is a coverage candidate, not a currently reproduced failure
or authorization to implement/run it. Preserve the earlier probe's validation
limits recorded in current.md.

## Naming constraints and retired pending work

The former naming task depended on a Git-ignored TODO.md that is no longer
present. Current scoped source review found no my/ definitions; the remaining
non-emarccs definition forms are declarations of external package/Emacs variables.
There is no supported concrete rename list to resume, and no naming prerequisite
blocking future layout work. Re-establish a specific target before new renaming.

The owner deliberately preserves emarccs--org-roam-blog-* despite the feature
being emarccs-org-roam-blog: the double hyphens express distinct privacy scopes.
This is a design constraint, not an outstanding defect.

Inputs cleanup, cross-repository library extraction, standalone overlay repair,
its equivalence checks and README synchronization are committed; they are no
longer backlog items.
The shared library may intentionally contain logic unused by Emarccs. The older
~/nixos/pkgs/lib/ comparison was historical; the current shared-library input
comes from personal-nixpkgs. Do not assume the reference copies stay synchronized.
