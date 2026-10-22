# Backlog

## Non-blocking: normalize emacsPackages.emarccs

The owner requests a future normalization pass over emacsPackages.emarccs
(pkgs/emacsPackages/emarccs), aiming to minimize byte-compilation warnings and
handle dependencies carefully. This is non-blocking: it does not gate the
completed migration, current builds or unrelated work, and it is not a promise
of zero warnings.

Review actual diagnostics and address their causes in declarations, compile-time
macro availability and configuration code. Audit direct/indirect, compile-time/
runtime and optional dependencies; align packageRequires and Elisp loading/
use-package declarations with actual requirements while preserving intended
lazy loading and configuration behavior. Record any intentionally remaining
warnings rather than hiding them with blanket suppression.

A targeted read-only comparison found 80 distinct use-package names and an
org-edna direct-dependency omission. The owner subsequently committed its
addition, bringing the direct packageRequires argument count from 75 to 76;
this specific finding is resolved and must not be re-added as pending work.
Other unmatched names are seven Emacs built-ins (dired, dired-x, eglot,
lisp-mode, recentf, savehist, which-key) and internal
emarccs--org-extension-block. No new build/test or transitive-dependency audit
was performed for that correction. The broader warning/dependency review above
remains non-blocking and incomplete.

This entry records scope and motivation only. No source changes, dependency
updates, warning-policy changes or build/test runs are authorized by adding it.

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
