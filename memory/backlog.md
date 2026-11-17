# Backlog

## Closed: README shared-foundation, ownership and formatter alignment
The README has been updated and committed for the current architecture:
package ownership (upstream Org-TeXmacs and Org-roam flake inputs, local
overlays, sources), Nix outputs, the texmacs-with-fandol-and-math-syntax
resource package, the generated math syntax, package-owned tests and flake
aggregation, withProgress and the snippet reorganization. The earlier
shared-foundation/formatter backlog is therefore closed.

The intermediate treefmt state that excluded `*.el` (6ea3416) was superseded
by the restored formatting check (40e0945): current treefmt formats Nix,
Elisp, Org and gitignore files with flakeCheck = true and excludes only
`*.patch`, `LICENSE` and `flake.lock`. Do not record Elisp formatting as
still disabled.

One residual documentation nuance existed after the main alignment and is
now resolved by commit 5b3215d: README previously said personal-nixpkgs's
nixpkgs, flake-parts and treefmt-nix dependencies all follow this
repository's corresponding inputs, while only nixpkgs has a root-level
follows declaration. The commit rewrites the paragraph to describe the
shared mkFlake interface and helper set without claiming the provider's
internal dependency follows. No README edit remains pending for this item.

## Non-blocking: normalize emacsPackages.emarccs
The owner requests a future normalization pass over
pkgs/emacsPackages/emarccs, aiming to minimize byte-compilation warnings and
handle dependencies carefully. This is non-blocking: it does not gate the
current state, builds or unrelated work, and it is not a promise of zero
warnings. turnCompilationWarningToError remains false for emarccs
(org-include-inline and org-workbench enable it), and package-lint keeps its
explicit, narrow exemptions.

Review actual diagnostics and address their causes in declarations,
compile-time macro availability and configuration code. Audit
direct/indirect, compile-time/runtime and optional dependencies; align
packageRequires and Elisp loading/use-package declarations with actual
requirements while preserving intended lazy loading and configuration
behavior. Record any intentionally remaining warnings rather than hiding
them with blanket suppression. Keep the checkInputs (package-lint) versus
runtime packageRequires distinction.

A targeted read-only comparison previously found 80 distinct use-package
names and an org-edna direct-dependency omission. The owner committed its
addition (direct packageRequires count 75 -> 76); that specific finding is
resolved and must not be re-added as pending work. The basic configuration
cleanup committed as 5b3215d resolves several concrete configuration issues
(frame geometry alist handling, compilation buffer matching, Savehist
variable, hook notation, unused constant, redundant self-require) but does
not complete this normalization entry: no dependency audit, warning
inventory, strict compilation policy or full use-package review is
established by it. The broader warning/dependency review above remains
non-blocking and incomplete. No
source changes, dependency updates, warning-policy changes or build/test
runs are authorized by this entry.

## Candidate regression coverage: Org-TeXmacs frontend autoloads
The earlier Org-TeXmacs issue established two distinct failure modes:
trivialBuild installed sources without ELPA descriptors/autoloads, and a
narrowed files recipe omitted ox-texmacs.el. The org-texmacs recipe is now
upstream-owned; the local overlay only selects the TeXmacs program.
Current startup-smoke checks the emarccs entry interfaces and real package
activation, and package-availability-smoke only runs locate-library over
packageRequires; no maintained test verifies that the three Org-TeXmacs
frontend commands (org-texmacs-export-as-texmacs,
org-texmacs-export-to-texmacs, org-texmacs-export-to-pdf) autoload from the
installed package.
Consider a bounded batch regression check of frontend library presence and
command/autoload availability without eager require of ox-texmacs or
invoking TeXmacs/export. This is a coverage candidate, not a currently
reproduced failure or authorization to implement/run it. Preserve the
earlier probe's validation limits recorded in current.md.

## Non-blocking: AAS per-buffer isolation reproduction
The Scheme snippet work exposed a likely upstream AAS state-isolation
defect: shared mutation of the defvar-local aas--current-prefix-maps default
can leak expansion state across buffers in one process. The history,
observed failure, static hypothesis and evidence limits are recorded in
architecture.md under "Historical Scheme isolation failure and potential
AAS defect". This is not a diagnosed Emarccs build defect: the final
configuration removes AAS from Scheme and its tests pass (owner-reported).

Future investigation should first build a minimal AAS-only reproduction with
two buffers, checking state before/after completing a trigger and after
failed expansion, then decide on an upstream patch (for example nil default
plus lazy per-buffer initialization) and regression tests. No execution,
dependency update or upstream PR is authorized by this entry.

## Validation candidate: existing-profile behavior under the new resource layout
All font/cache probes in current.md targeted the former texmacs-fandol
TEXMACS_FONT_PATH wrapper and the then-current org-texmacs/TeXmacs
versions. They do not demonstrate that
texmacs-with-fandol-and-math-syntax has the same existing-profile behavior,
nor that it is fixed. If and when a real validation need arises, isolate
fresh versus existing TeXmacs profiles and check font discoverability, style
loading (emarccs-math.ts) and Org PDF export separately. Do not adopt cache
migration helpers, global Chinese language defaults or Source Han font plans
without owner confirmation.

## Current configuration policies (reviewable, not mandated)
The basic configuration still sets explicit backup/auto-save/lockfile
behavior (make-backup-files t, auto-save-default nil, create-lockfiles nil,
with cache/backups and cache/auto-save transforms), redirects
temporary-file-directory to ~/tmp/emacs/ and assigns display-buffer-alist
as a whole. These are current configuration policies. Reviewing or changing
them is not a decided task, and no specific refactor (multi-instance state
isolation, enabling lockfiles or auto-save, or a temporary directory layout
change) is mandated by this entry.

## Naming constraints and retired pending work
The former naming task depended on a Git-ignored TODO.md that is no longer
present. Current scoped source review found no my/ definitions; the remaining
non-emarccs definition forms are declarations of external package/Emacs
variables. There is no supported concrete rename list to resume, and no
naming prerequisite blocking future layout work. Re-establish a specific
target before new renaming.

The owner deliberately preserves emarccs--org-roam-blog-* despite the
feature being emarccs-org-roam-blog: the double hyphens express distinct
privacy scopes. This is a design constraint, not an outstanding defect.

Inputs cleanup, cross-repository library extraction, standalone overlay
repair, its equivalence checks, README synchronization and the upstream
package migrations are committed; they are no longer backlog items. The
legacy debug module and the old global document-structure insertion
shortcuts are removed and committed (5205b016, 65a3385); they are not
pending work and must not be re-added as tasks. The
shared library may intentionally contain logic unused by Emarccs; the
current shared-library input comes from personal-nixpkgs and reference
copies are not assumed to stay synchronized.
