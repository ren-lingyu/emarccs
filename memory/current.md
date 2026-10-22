# Current memory

## Work entry points
Read architecture.md for initialization, package ownership, Nix interfaces and
Org workflows; backlog.md for deferred work; reconstruction.md for historical
evidence limits. Use public GAW status/check for live lifecycle state.

## Current state: README synchronization committed
The owner authorized updating README after the backlog review. The project
worktree was clean at start; the factual baseline is the committed standalone
overlay fix, compared with the last README update at the earlier Elisp source
normalization phase. README.org is now updated for Nixpkgs/MELPA packaging,
configuration-vs-wrapper ownership and actual directories, startup phases,
three wrapper outputs/legacyPackages, standalone overlay use, shared-library
merge/follows wiring, package overrides/runtime supply and seven check families.
Old Twist recipes/locks/update apps and bootstrap advice descriptions are gone.
The document keeps the minimum Emacs version at 31.1, existing lint exemptions
and stable maintenance/initialization conventions. It contains no build-result
or experiment log. All changed factual areas were checked against source and
root lock; concrete entry paths exist, Org source-block pairs match, obsolete
references are absent, and diff --check passes. No Nix evaluation, build/test,
formatter or project index/history write was performed by the agent. The owner
subsequently committed the one-file update as "docs(readme): describe Nixpkgs
packaging and standalone overlay". Read-only confirmation found that expected
README change in HEAD and the ordinary project worktree/index clean. The current
checkpoint associates this inspected documentation commit; it does not imply
new test execution. README synchronization is removed from backlog. Its remaining
coverage item is the candidate custom-package frontend/autoload regression test;
naming privacy rules remain constraints, not pending renames.

## Current state: standalone overlay fix committed
The owner committed the seven-file change as "fix(overlays): make the default
overlay usable independently". Read-only confirmation found the expected wrapper
package extraction, direct overlay export and equivalence checks in HEAD and
an ordinary project worktree/index with no changes. This checkpoint associates
the inspected resulting project commit; tests below ran before the commit and
were not rerun during confirmation. README was synchronized in the later
documentation commit described above.
No implementation remains pending for the authorized overlay task.

## Backlog review
Read-only inspection after the overlay commit found the project worktree clean.
The backlog was reduced to the deliberately deferred README synchronization and
an explicit candidate for installed Org-TeXmacs frontend/autoload regression
coverage. Completed input/library/overlay work is retired from pending tasks.
The ignored TODO.md is absent; scoped definition searches found no my/ names,
and non-emarccs forms only declare external Emacs/package variables. Therefore
the old naming-before-layout prerequisite has no supported concrete target and
is retired, without asserting an exhaustive namespace audit. Intentional
emarccs--org-roam-blog naming remains a constraint. Only GAW memory was edited;
no project source/docs, tests, builds, index or history were changed.

## Completed implementation: overlay equivalence checks
The owner authorized adding overlay regression checks using the existing
<package>-<test> naming. flake.nix now passes its actual exported default overlay
to tests/. tests/default.nix imports pkgs.path once with the existing pkgs.config,
the host system and only the supplied overlay; it shares this independent
package set across variants. Existing pkgs still supplies callPackage/tools.
It generates emarccs-overlay-equivalence, emarccs-pgtk-overlay-equivalence and
emarccs-gtk-overlay-equivalence. tests/overlay-equivalence/default.nix asserts
actual/expected drvPath equality during evaluation, then returns an empty
runCommand result named for the wrapper. The assertion discards drvPath string
contexts through boolean comparison, so wrappers are not build inputs of the
check. Missing overlay exports fail ordinary attribute lookup.
Validation on x86_64-linux: all three new checks passed via a timeout 120s
offline/no-write-lock-file/no-link nix build of a selected source snapshot that
includes the untracked new test file. Logs showed only three tiny check results
built, no wrapper rebuild. Two offline eval negative controls also passed:
an empty overlay failed on missing emarccs despite the existing pkgs already
containing that package; an overlay producing a different derivation failed the
explicit assertion. nixfmt was applied to the three edited/new Nix files and
diff --check passed. All 65 snapshot files were compared byte-for-byte to the
current sources after validation. No full-suite rerun was needed or performed.
No project staging, commit, lock update or result link was done by the agent.
The owner subsequently staged and committed all seven project paths, including
the new test file. The authorized implementation and review/commit next action
are complete. Earlier org-texmacs findings below were reviewed for this memory
snapshot and retain their original validation limits.

## Current verification: package-directory wrapper strategy passes
The owner abandoned the explicit wrapper constructor in flake.overlays.default
and moved the common wrapper constructor/startup injection to
pkgs/emarccs/package.nix. Root overlays provide emarccs and derive GTK/PGTK
variants through final_.emarccs.override with the corresponding final Emacs.
The first revision retained easyOverlay/overlayAttrs and inherited packages
from perSystem.pkgs. Independent exported-overlay evaluation failed because
locked easyOverlay forces perSystem.pkgs to external prev, where emarccs is
absent; flake's own packages still evaluated. That failure is now resolved:
the owner removed easyOverlay/overlayAttrs and exports
flake.overlays.default = lpkgs.overlays.default directly. perSystem uses the
same local overlay and packages inherits all three wrappers.
On the owner's follow-up request, offline independent import of locked Nixpkgs
with only flake.overlays.default passed on x86_64-linux. All three wrappers
expose the matching configuration package/scope and exactly match the drvPaths
of flake.packages for their names. A timeout 120s nix build --offline
--no-write-lock-file --no-link --print-out-paths -L --impure expression realized
all three independently constructed wrappers and startup-smoke derivations
created through pkgs.callPackage; all six outputs succeeded using cached
results. The smoke derivations are the same outputs freshly executed during
the earlier explicit-overlay test below. This latest run did not freshly
execute cached scripts. No interactive startup, cross compilation, other
systems or full-suite check was performed. Both Nix commands had 120s bounds.
Staged diff --check passed. At this validation phase the changes were the
owner's five wrapper/flake paths; the later regression-check implementation
adds tests/ edits, and the resulting seven-path change is now committed. The agent
made no project source/index changes, lock update or result link; tests used
offline mode. The overlay task is verified complete and the owner has committed
it; these tests originally targeted the staged state. The resulting commit is
associated by the current checkpoint after inspection. These checks do not
resolve unrelated interactive/export issues. Shared-library import integration
is exercised by these successful current-overlay evaluations/build realizations.

## Earlier verification: abandoned explicit default overlay strategy
On 2026-10-23 the owner requested testing flake.overlays.default. Current staged
flake.nix explicitly composes the package overlays and all three Emarccs wrapper
constructors, removes easyOverlay, imports Nixpkgs with that exported overlay
for perSystem, and exposes packages by inheriting those pkgs attributes. No
project code/index changes were made by the agent during this test.
Independent offline evaluation imported the locked Nixpkgs with only the
consumer flake's overlays.default, using the current Git worktree flake. On
x86_64-linux, emarccs/emarccs-pgtk/emarccs-gtk all evaluate, expose the matching
configuration package/scope and grammar propagation, and have exactly the same
drvPaths as flake.packages for their names. This also exercises the imported
personal-nixpkgs library in the current integration.
A separate timeout 120s nix build --offline --no-write-lock-file --no-link
--print-out-paths -L --impure expression realized those three independently
constructed wrappers and the three startup-smoke derivations instantiated with
pkgs.callPackage. It exited zero: wrapper outputs were cached and all three
smoke derivations freshly executed, each printing Emacs 31.1 and startup-smoke
ok. Existing smoke coverage checks disabled-user-init/lazy interfaces, installed
configuration resolution, exact system grep/rg/ls resolution with an empty
incoming PATH, and real package activation with initializer substitutes.
No interactive startup, cross compilation, other systems or full-suite run was
performed. Each Nix command had a 120s timeout; smoke has its existing 20s bound.
No lock update, result link, dependency download or test-source change occurred.
Only the owner's staged flake.nix differs in the ordinary project worktree.
These are tests of the staged working state, not a new exact project commit;
no new project parent is claimed. Pre-existing uncheckpointed org-texmacs memory
was preserved; this test does not resolve unrelated interactive/export issues.

## Earlier org-texmacs diagnosis and package migration
These findings predate the current overlay task. The package migration is now
committed ("build(pkgs): use melpaBuild to generate package autoloads"). Current
source inspection confirms the final explicit MELPA defaults and Scheme-worker
selection described below. Earlier intermediate file-selection failures and
then-staged states are historical. No fresh frontend/export or full interactive
acceptance is implied by the current overlay tests. The original batch probe's
exact uncommitted source provenance is not reconstructed or assigned a parent.

The owner reports missing org-texmacs-export-* commands in nix run
.#emarccs-pgtk, despite loading the package in their custom.el. Read-only
inspection confirms the configuration dependency includes org-texmacs, with no
explicit reference in the configuration Lisp. The owner authorized reading
~/Projects/org-texmacs: its clean HEAD matches the consumer's pinned source
revision. That source is version 0.5.0 although the consumer derivation still
labels it 0.4.0. Its upgrade documentation explicitly makes main-library exports
noninteractive APIs and moves three interactive commands to ox-texmacs:
org-texmacs-export-as-texmacs, org-texmacs-export-to-texmacs and
org-texmacs-export-to-pdf. Main org-texmacs does not require ox-texmacs.
The frontend commands have autoload cookies and (interactive nil org-mode).
The owner subsequently authorized reading custom.el:
it contains a use-package org-texmacs declaration with settings, but no
ox-texmacs loading. The owner reports explicitly requiring ox-texmacs via M-:
restores the commands, then authorized read-only inspection of relevant Nix
store outputs and build/startup sources to investigate startup/autoload behavior.
The existing result PGTK output installs org-texmacs as flat site-lisp .el/.elc
files without autoloads or a package descriptor, and without an elpa entry.
Its site-start calls package-activate-all before the early initializer and
regular initialization/custom.el. Installed Emacs package-activate.el discovers
descriptors and loads their autoloads; it does not scan arbitrary source cookies.
The exact locked Nixpkgs trivial.nix, read from its public upstream URL, only
byte-compiles/installs sources by default; it generates neither autoloads nor
descriptors. The gap originates in the trivialBuild packaging contract, so
moving/repeating activation alone cannot fix this inspected output. Earlier
assumptions that package-provided autoloads existed are superseded.
Startup smoke checks citar/consult/org activation, while availability checks
only locate libraries; neither covers this custom-package command gap. Other
custom packages also use trivialBuild, but broader effects are unverified.
The owner subsequently authorized migrating every current trivialBuild package
to melpaBuild. All seven package.nix files now use melpaBuild: emarccs,
org-include-inline, org-roam-blog, org-roam-include, org-roam-organize,
org-texmacs and org-workbench. Each recipe explicitly includes root *.el files,
matching the former source installation scope. org-texmacs additionally includes
org-texmacs-worker.scm in its recipe so it stays beside its Lisp library in the
ELPA layout; its obsolete flat-site-lisp postInstall was removed. The owner
clarified that 0.5.0 is prepared Elisp metadata, not a formal release, and
restored the Nix version to 0.4.0. On request to add melpaVersion where needed,
the agent added melpaVersion = "0.5.0" to org-texmacs, retaining version 0.4.0.
The owner also broadened its files selection to *.el/*.scm; preserve this edit.
Other migrated packages' source versions agree with their Nix version values
(org-include-inline has an uppercase VERSION header). The owner subsequently
requested explicit melpaVersion values for these packages too: emarccs,
org-include-inline, org-roam-blog and org-roam-include use 0.1.0;
org-workbench uses 0.3.0; org-roam-organize uses 0.7.0.
Org retains its existing explicit 10.0pre value.
emarccs excludes melpaBuild from
the args-derived packageRequires list in place of trivialBuild. Source pins,
patches, other dependencies, startup scheduling and custom.el were not changed.
Scoped diff --check passed and source search found no remaining trivialBuild
references in pkgs. The owner subsequently changed the six fetched packages'
Nix version strings to dated unstable versions, retained their explicit
melpaVersion values, and reported all builds passed. The new result points to
the PGTK wrapper containing ELPA installations with descriptors/autoloads for
all seven migrated packages. org-texmacs includes all three interactive frontend
autoloads targeting ox-texmacs and its Scheme worker beside the Lisp libraries.
The owner explicitly authorized one bounded batch verification. Running
timeout 30s result/bin/emacs --batch -q with an inline probe exited zero:
all seven packages activated; all three frontend commands satisfied commandp
and autoloadp and target ox-texmacs, while ox-texmacs remained unloaded. The
probe disabled JIT native compilation and redirected user-package/quickstart
lookup to nonexistent paths; it loaded no personal init/custom.el, invoked no
export and performed no networking. The missing-autoload defect is resolved
in this built PGTK output without eager frontend require or startup changes.
This is activation-level runtime verification, not full interactive startup or
export acceptance. The owner then reported commands still absent in their
interactive session: do not treat the isolated probe as end-to-end resolution.
Requested a read-only M-: report from that session before any manual require or
reactivation: major-mode, commandp/function definition for export-to-pdf,
locate-library ox-texmacs, membership in package-activated-list, and
read-extended-command-predicate. The supplied report has major-mode=org-mode,
commandp=nil, function definition=nil, locate-library ox-texmacs=nil,
org-texmacs activated=t, and filter=transient-command-completion-not-suffix-only-p.
This excludes mere completion filtering; the frontend library is unavailable.
Requested a second read-only M-: report of package descriptor versions/dirs,
main library location, loaded check-setup definition source, quickstart path
and executable to identify the selected package. No explicit load-path or
package-system mutation was found in configuration Lisp/custom.el.
The second report identified a different live wrapper/dependency output than
the earlier successful probe. Reading that exact live ELPA directory confirmed
ox-texmacs.el/.elc are absent, and its autoload file contains no frontend command
definitions. Current owner-edited org-texmacs files selection is
("${finalAttrs_.src.repo}*.el" "${finalAttrs_.src.repo}*.scm"), which excludes
ox-texmacs.el. This explains activated=t with no frontend library/commands;
it is a later file-selection regression, not a demonstrated startup failure.
Required correction is adding "ox-texmacs.el" explicitly to that recipe,
then rebuilding/restarting the intended wrapper. Earlier successful runtime
verification applies only to the output built with the wider *.el selection.
No project file was changed during this diagnosis.
The owner later confirmed the narrowed glob omission and reported fixing it;
read-only inspection subsequently found ox-texmacs.el explicitly restored in
their staged recipe. They then authorized adopting MELPA defaults for the seven
custom packages, excluding Org, and specified that even defaults be explicit.
Current edits therefore use files = "(:defaults)" in emarccs, org-include-inline,
org-roam-blog, org-roam-include, org-roam-organize and org-workbench;
org-texmacs uses (:defaults "org-texmacs-worker.scm"). Org is unchanged.
Those file-selection edits were later committed with the package migration.
No direct frontend-specific probe was rerun for that final selection; current
overlay builds/smoke are later passing evidence with their own narrower scope.
custom.el still declares only
org-texmacs; no obvious explicit command filtering was found in custom.el or
emarccs-basic.el. Native startup source confirms site-start precedes early init,
automatic package activation and before-init-hook. Personal init/early-init and
quickstart state have not been inspected. Persistent activation test coverage
has not been added.
No project edits or index changes were made during that diagnosis/verification.
The then-staged/unstaged package edits are now committed; the ordinary project
worktree is clean at current confirmation.

## Current state: Nixpkgs migration committed
The owner committed the migration as "build(nix): replace Twist packaging with
Nixpkgs". Read-only confirmation found that HEAD contains the reviewed 93-file
migration and that the ordinary project worktree/index are clean. This
checkpoint associates that inspected committed migration as a project parent;
it does not imply tests were rerun after the commit. Pre-commit agent flake
check passed with all 19 checks satisfied from existing outputs, and the owner
reported all build targets passed. Inputs and README remain deliberately
unchanged. No further implementation is pending in this migration's authorized
scope. Future work requires a new objective; deferred items remain in backlog.md.

## Follow-up: committed generic library hardening
After the migration commit, the owner staged and then committed a further
lib/packages.nix update as "fix(lib): validate discovery boundaries and scope
requirements", confirmed by read-only log inspection during the next task. Static review found unchanged
public arguments/call sites, explicit errors for descendant overlays under a
derivation leaf, explicit missing-newScope diagnostics for scope construction,
and rejection of descendant modules below a discovered module entry. The latter
replaces the earlier behavior that stopped recursion at the parent module and
silently ignored its descendant modules; it is a stricter library contract.
The unused private mkScope_ helper was removed and redundant parentheses were
simplified. Scoped staged diff --check passed. No build/evaluation/test was run
for this follow-up, and the migration's earlier passing checks do not validate
these new branches. No source edits or project Git writes were made by the agent.

## Completed follow-up: inline pure package overrides
The owner explicitly requested folding pure overrides into overlay.nix and
removing their package.nix files. Consult, ripgrep and treesit-auto are the three
matching packages; their overrideAttrs bodies now live in the corresponding
overlay.nix files and their package.nix files are deleted. Consumer propagation
and treesit-auto's existing grammar-name patch are preserved. System ripgrep
and GNU grep use outer pkgs explicitly; treesit grammars use the final Emacs
scope. Other packages construct derivations and retain package.nix.
Overlay-file-based discovery still makes these three derivation leaves eligible
for legacyPackages without package.nix; no library/caller change is needed.
Scoped source/diff review and diff --check passed. The owner reports running
full pkgs/ build validation: all targets succeeded using existing cached outputs.
This supports the expected file-organization-only effect without introducing
rebuilds; it is owner-reported build evidence, not fresh execution of tests.
The agent did not repeat builds or checks. Read-only confirmation subsequently
found the owner committed the six-file change as "refactor(pkgs): inline package
overrides into overlays" and the ordinary project worktree/index are clean.
This checkpoint associates the inspected committed result; no project index or
history was changed by the agent. Inputs and README remain untouched. The
requested inlining and owner build validation are complete; no further action
is pending in this task.

## Completed follow-up: removal of unused inputs
The owner removed Twist, nix-to-lisp, MELPA, GNU ELPA and NonGNU ELPA from root
inputs and committed flake.nix/flake.lock as "chore(flake): remove unused twist
and package registry inputs". llib now imports ./lib directly, removing
the unused nix-to-lisp elisp binding. Read-only review confirmed lock cleanup
also removes the transitive elisp-helpers/fromElisp nodes, while every retained
non-root lock node is unchanged. Remaining direct inputs are nixpkgs,
flake-parts and treefmt-nix. Scoped searches found no old input or llib.elisp
references in active Nix code; melpaBuild/melpaVersion in the Org derivation are
Nixpkgs builder/metadata names, not dependencies on the deleted MELPA flake input.
Staged diff --check passed. No Nix evaluation/build/check was run for this
follow-up. The earlier build/cache report predates this input cleanup. README
remains intentionally unchanged. No agent source edits or project Git writes
were made. Read-only confirmation found the two-file cleanup committed and the
ordinary project worktree/index clean. This checkpoint associates that inspected
commit as a project parent. Input cleanup is complete; README remains deferred.
No new build/check result is inferred from the commit confirmation.

## Completed follow-up: reusable Nix library extraction
The owner removed lib/packages.nix, retained lib/default.nix as an empty local
extension function, and committed the new personal-nixpkgs input plus lock and
call-site changes as "refactor(lib): consume shared helpers from personal-nixpkgs". The input points at ren-lingyu/nixpkgs and follows this repository's
nixpkgs, flake-parts and treefmt-nix. specialArgs.llib now uses the external
lib.mergeAttrsRecursive with allowOverrides = false to combine that external
library with the local extension; lpkgs and pkgs/default.nix still consume the
same llib.packages interfaces. No external package overlay is appended here:
the new input is used for its shared library.
Read-only lock comparison found exactly one new node, personal-nixpkgs, and no
changes to existing non-root nodes. Read-only confirmation found the four-file
extraction committed and the ordinary project worktree/index clean. This
checkpoint associates the inspected project commit as a non-first parent.
Scoped diff --check passed before commit. Public web retrieval initially failed,
but the owner then explicitly pointed
to ~/nixpkgs for read-only inspection. Its lib/default.nix, packages.nix and
merge-attrs-recursive.nix match the Emarccs input's locked revision exactly;
the extracted packages.nix is byte-identical to the pre-extraction Emarccs file.
The input exposes flake.lib containing packages and mergeAttrsRecursive. Static
inspection confirms allowOverrides = false recursively rejects overlapping leaf
definitions while merging attribute-set namespaces, with derivations treated as
leaves; unique leaves are not forced by conflict checking. The empty local
extension cannot introduce conflicts. The local reference repository is clean
and one commit ahead of the locked input: only flake.nix gained that library's
own checks wiring, with no changes to its library exports or implementations.
No input pin update is required for the current consumer API. No Nix evaluation,
build/check or source edit was performed by the agent. Earlier passing builds
predate this extraction and are not validation of it. README remains unchanged.
Extraction and static API review are complete. Nix integration validation has
not been reported or run for this extraction; no new check is inferred from
commit confirmation. README remains the deliberately deferred documentation task.

The following implementation/validation sections describe the completed phases;
references to their then-staged or uncommitted state are historical.

## Completed work: tests reconnected to the Nixpkgs package architecture
The owner requested adapting and reconnecting the existing tests. Project edits
are limited to flake.nix and tests/; no source-package behavior, dependencies,
inputs, index or README changes are part of this task. The new checks take an
explicit configurationPackage and, where needed, grammarPackage. They cover all
three configured Emacs outputs. Startup ERT reads the generated wrapper's real
Emarccs scheduling form and uses bounded batch substitutes, replacing old
bootstrap/advice contracts. Runtime smoke verifies installed-package resolution
and disabled-user-init behavior. Compilation/lint use configurationPackage.src;
availability follows packageRequires; grammar enumeration uses the supplied
output without adding it to treesit-extra-load-path.

Agent-run validation on x86_64-linux passed: timeout 120s nix flake check
--no-write-lock-file --keep-going -L. All 19 exposed checks (six families for
emarccs/emarccs-pgtk/emarccs-gtk plus treefmt) were evaluated and satisfied;
the final run reused previously built checks and rebuilt the changed treefmt
source check. Startup-order passed seven bounded batch ERT tests per variant.
Runtime smoke verified that batch/-q leaves configuration uninitialized, then
explicit require resolves the provided installed package and stays lazy.
Lint checks all 17 source libraries: 15 approved personal-configuration
exemptions and zero other diagnostics. Availability checks 75 declared direct
dependencies, mapping the AUCTeX attribute to the tex-site library. Grammar
runtime checks find and create parsers for all 334 supplied grammar libraries;
the Nixpkgs wrapper's actual propagated lookup works without test-added paths.
Compilation/lint/ERT run against the correct per-Emacs variant package.

The first compile-test run failed because dependency autoload expansion needed
cl-defsubst; the compiler harness now explicitly requires cl-lib before loading
autoloads. The first ERT run used a slash in a basename-matching recursive
search regex and failed to find the installed library; corrected before all
seven tests passed for all three variants. No package/configuration behavior
was changed to fix either test harness issue. Byte compilation still allows
existing warnings; this is not a warning-free or full interactive acceptance
claim. Other platforms, external executable workflows and full initialization
were not tested. No index changes were made: the owner's migration remains
staged, with the agent's flake/tests changes unstaged on top.

No new archive was warranted: these are maintained project test sources, not
an independent disposable experiment. Current memory distills the method and
results; routine logs in tmp/ are not required for recovery. The old standalone
experiment archive stays unchanged. Next action is owner review/commit of the
migration plus tests. README still describes parts of the old architecture and
remains outside scope.
Entry Commentary was subsequently corrected in the cleanup below.

## Checks generation interface
The owner adopted and authorized a further tests/ refactor. perSystem now
returns an ordinary attribute set: packages uses mapAttrs on the inline three
base Emacs entries, and checks imports tests/ with { pkgs, packages, lib },
where packages = config.packages. No mergeAttrsList/zipAttrsWith wrapper,
intermediate Emacs variant set, name-to-variant table or custom passthru is
needed. tests/default.nix owns concatMapAttrs enumeration and name prefixes,
then invokes all six test derivations through pkgs.callPackage. Individual
tests declare runCommand, coreutils, lib and, for lint, emacsPackages rather
than receiving the complete pkgs. Wrapper/configuration/grammar arguments
remain explicit project-specific parameters to individual tests.

The locked Nixpkgs wrapper exposes wrapper.emacs and explicitRequires as
ordinary derivation attributes. Its scope-specific base Emacs has passthru.pkgs
pointing to the overridden package scope (see Nixpkgs wrapper.nix and
pkgs/top-level/emacs-packages.nix). tests/ obtains configurationPackage and
grammarPackage from wrapper.emacs.pkgs, preserving the actual variant and
local overlays. Offline evaluation of all three wrappers confirmed that this
configuration package is one of the wrapper's explicitRequires.

Before/after offline evaluation of this final refactor showed identical
names and drvPaths for all three packages and all 18 test derivations.
The final timeout 120s nix flake check --no-write-lock-file --keep-going -L
passed on x86_64-linux; test outputs were reused unchanged and treefmt rebuilt
successfully. No project staging, lock update, dependency change or Elisp test
behavior change occurred in this generation/interface refactor. Earlier
expression-only mapping proposals are superseded by this implemented interface.

## Completed migration cleanup
The owner authorized restoring runtime executable supply, checking real package
activation, removing the obsolete Scheme byte-compile builder, and correcting
flake/entry descriptions. Inputs and README stay unchanged. Unused library
bindings/helpers stay for now; the owner already cleaned treefmt exclusions.
The owner subsequently clarified that lib/packages.nix is intended for extraction
as a standalone cross-repository library. Local non-use alone does not establish
that generic logic is redundant. Another implementation reference identified by
the owner is ~/nixos/pkgs/lib/. A subsequent read-only comparison of its
packages.nix with Emarccs lib/packages.nix found them byte-identical (5,518 bytes
each) before the subsequent discovery changes. The owner clarified that
legacyPackages should expose pure-override packages too, for individual builds,
and changed discovery to follow overlay files and the corresponding derivation
attributes rather than requiring package.nix. The agent then renamed the
Emarccs library's overlayPath_/overlayPath parameters to overlayFile_/overlayFile,
including both public helpers and pkgs/default.nix callers; the private mkScope_
parameter was aligned as well. No NixOS repository files were modified. This
rename was initially verified by scoped search and diff --check. Subsequent
final validation below also covers the updated discovery/interface.
The owner prefers consumer-local overrides: Consult propagates system GNU grep
and ripgrep; the ripgrep Elisp package propagates system ripgrep. New overlay
files explicitly select outer pkgs.ripgrep to avoid the same-named Elisp package.
The Emacs scope does not expose pkgs directly; its callPackage can retrieve the
outer system pkgs binding. Dired has no separate package derivation here.
The owner suggested adding coreutils directly through flake withPackages;
source inspection confirms the wrapper accepts ordinary derivations and links
bin directories into its runtime PATH. This is now the chosen coreutils supply.
No central system-tool list remains on the emarccs derivation.

A batch probe against the pre-cleanup pgtk wrapper executed the actual
startup form with real package-activate-all, replacing only personal config
initializers. cl-lib was absent before activation and present afterward; no
warnings/errors occurred and both initializer substitutes ran. The removed old
Citar patch is therefore not a reproduced runtime bug. The independent compiler
still needs its explicit cl-lib preload when manually loading autoload files.
Startup-smoke now tests real activation and explicit executable resolution under
an empty incoming PATH. It verifies Citar/Consult/Org are activated, captures
activation error diagnostics and observes both initialization substitutes.
No ERT/cl-lib preload, package-activation substitute or interactive startup is
used by this smoke test. Existing startup-order ERT retains deterministic
substitutes for its ordering cases.

Agent validation passed on x86_64-linux: timeout 120s nix flake check
--no-write-lock-file --keep-going -L against an explicit path: source snapshot.
All 19 checks passed, including all three updated startup-smoke derivations,
seven startup-order ERT cases per variant, compilation, lint with existing
approved personal-configuration exemptions, availability, grammars and treefmt.
The snapshot copied current tracked files plus the four new Consult/ripgrep
Nix files, excluding the deleted builder; comparison after the checks found only
one removed blank line in Consult package.nix; all other files matched exactly.
This avoids staging those new files
just to make the Git flake include them. Build warnings remain accepted as in
the previous run; this is not a full personal configuration startup acceptance.

The obsolete Scheme builder was deleted and flake/entry descriptions corrected.
Inputs, lock, README, private library helpers and project index were unchanged
by this cleanup. The owner subsequently staged all project changes, including
the new consumer overlay files and discovery/interface changes. There are no
unstaged project changes at final review. That review checkpoint had no exact
committed project snapshot to associate. The owner has now committed the
reviewed migration; the current checkpoint associates the inspected result.
Maintained tests and distilled memory suffice; no additional raw-evidence
archive is warranted.

Final validation and commit assessment: the owner reported that their own
nix flake check and all nix build targets passed. At their request the agent
ran timeout 120s nix flake check --no-write-lock-file --keep-going -L once on
the current repository, after all discovery/naming edits were staged. It exited
zero with all checks passed on x86_64-linux. All 19 check derivations were
satisfied from existing outputs (the log says running 0 flake checks); this run
did not freshly execute cached test scripts or test other systems. The agent
did not repeat the owner's builds. Inputs, root flake.lock and README remain
unchanged by explicit owner decision.

The staged migration is suitable as one standalone commit: packaging, local
overlays, source relocation, wrapper startup, old locks/recipes/framework
removal and adapted tests implement one coherent transition away from Twist.
Splitting is not necessary; separating them would require designing intermediate
working integration states. The reusable library supports this migration and
its future extraction is a separate objective. Staged diff --check succeeds
excluding patch payloads; diagnostics within the two new upstream patches are
context/upstream whitespace, not a functional blocker or a reason to rewrite
patches during this review. Suggested subject: build(nix): replace Twist
packaging with Nixpkgs. The owner subsequently used this subject and committed
the migration; the commit/review next action is complete. No project source,
index or history was changed by the agent during assessment or confirmation.

The following worktree inspection describes the starting state, before these
test edits. Its disconnected-test statements are historical; validation above
covers the new migrated working tree, not an exact committed project snapshot.

## Migration starting state: Nixpkgs architecture before test reconnection
Read-only inspection on 2026-10-22 found a substantial staged, uncommitted
migration after the committed project-library specialArgs change. This section
supersedes the older architecture/current-state descriptions below for the
working tree; earlier passing runs remain evidence only for their old scopes.
The owner asked for inspection, not implementation or new test execution.

- Root flake retains Twist and registry inputs but no longer uses Twist makeEnv,
  registries, lock/update apps or the former context interface. It now installs
  the local overlay into per-system pkgs and builds emarccs, emarccs-pgtk and
  emarccs-gtk via emacsPackagesFor/withPackages with only emarccs as an explicit
  seed. The root description still mentions Twist.
- lib/packages.nix discovers overlay/package namespaces; pkgs/default.nix
  exposes a combined overlay and selected legacyPackages. The emacsPackages
  overlay extends emacsPackagesFor through overrideScope, preserving variant
  package scope. The old recipe/override assertion framework is removed.
- Configuration moved from root lisp/ to pkgs/emacsPackages/emarccs/lisp/.
  Its trivialBuild derivation declares third-party packageRequires from explicit
  function arguments. Most Lisp modules were renamed without content changes;
  the bootstrap module is deleted and emarccs.el no longer registers advice.
- Startup is now injected into the Nixpkgs wrapper dependency derivation's
  site-start through a guarded buildCommand replacement. Under init-file-user,
  it activates packages, requires emarccs, calls emarccs-initialize-early, then
  registers emarccs-initialize on before-init-hook. Startup scheduling is thus
  owned by the wrapper, not require of the entry. Entry Commentary still
  describes the old registration contract.
- Local Org and the six previously missing packages now have package.nix and
  overlay.nix definitions. Org fetches official upstream and generates 10.0-pre
  metadata during build. org-texmacs gets an absolute TeXmacs executable path.
  The former global runtime executable aggregation is absent. The owner then
  restored a treesit-auto overlay: propagatedUserEnvPkgs includes the matching
  package scope's treesit-grammars.with-all-grammars, and a static patch restores
  five grammar library/init-symbol aliases. This has only been source-inspected,
  not evaluated or built. package.nix and overlay.nix also have unstaged edits.
  The old grammar test still searches for an emacs-treesit-grammars-named /lib
  path, whereas the new supply relies on Nixpkgs wrapper propagation; do not
  assume the actual runtime path retains the old naming/layout.
- The six old test families remain on disk unchanged, but the root tests import
  is commented out. Treefmt's own flakeCheck setting remains enabled; a future
  root flake check must not be mistaken for full restored test coverage.
- Reconnection requires explicit configuration-package parameters through
  tests/default.nix (owner requirement), not ../../lisp. Startup-order's old
  bootstrap/advice tests and smoke's named-advice and batch-loaded-entry claims
  conflict with the new startup contract. Lint main-file layout and source
  selection need adapting. Byte compilation is now part of package building,
  with warnings allowed for Emarccs; an independent compile check has a distinct
  purpose if retained. Availability tests should follow declared package
  dependencies. Grammar supply has been restored in source, but its runtime
  propagation and the grammar test's path-discovery assumptions remain to be
  verified; the test is still disconnected.
- README still describes root lisp/, Twist outputs and old startup scheduling.
  No documentation or project-source edits, builds, evaluations or tests were
  performed by the agent during this inspection. No current build success is
  established by the earlier owner-run checks or isolated experiment.

## Completed step: Elisp source-package normalization
The owner supplied detailed implementation guidance after accepting the
committed pure-emacs entry/mechanism removal and Lisp flattening. The baseline
also contains subsequent README/.gitignore presentation-only commits.
The owner committed the source-package normalization, including lisp/emarccs.el,
the package-lint check, README cleanup and the final startup-smoke Nix minimum
correction. Read-only inspection confirmed the reviewed commit subject and
change summary, committed interfaces/version boundaries and a clean project
worktree. The agent did not stage or commit project files.

The selected architecture is implemented:
- emarccs.el requires bootstrap, early-init and init interfaces, then uniquely
  registers the named emarccs-startup :before advice. It is the only startup
  registration owner; require does not initialize configuration.
- emarccs-bootstrap.el defines emarccs-bootstrap--before-user-init-file without
  registering advice/hooks. It preserves init-file-user/load-defaults meaning
  and delegates execution/return semantics to native :before advice.
- emarccs-initialize-early applies early settings once. emarccs-initialize
  retains module order and optional custom.el handling, guards recursive and
  successful repeat calls, and marks completion only after success.
- Functional modules remain configuration libraries with their original hooks
  and keys. Only actual use-package users gained compile-time macro requires;
  three parenthesis-only formatting corrections addressed lint diagnostics.
- The flake only adds lisp to load-path (eval-and-compile) and requires emarccs.
  No Emarccs Nix derivation/recipe, wrapper package-list change, third-party
  override/lock change, startup.el patch or new startup hook was introduced.
- Main source metadata is version 0.1.0, minimum Emacs 31.1 (existing
  delete-trailing-whitespace-mode usage requires it), with no fabricated full
  third-party dependency closure or independent-installation promise.

## Lint policy and validation
The owner explicitly chose full-source package-lint with narrowly documented
exemptions for personal-configuration reserved keys and with-eval-after-load
warnings. The check runs the public package-lint-buffer on all eighteen source
libraries, prints accepted diagnostics, and fails every other diagnostic.
The four entry/initialization interface libraries receive no exemptions.
The current result is fifteen approved diagnostics, zero other diagnostics.
Do not silently broaden this policy or claim a completely diagnostic-free lint.
Package-lint is separate test tooling, not a configuration runtime dependency.
The owner clarified the minimum-version boundary: keep emarccs.el/README at
31.1 and pass MIN_EMACS_VERSION=31.1 from tests/startup-smoke/default.nix.
The Lisp test's generic fallback remains 31.0; it need not duplicate the
project's explicitly supplied minimum. The attempted fallback change was
reverted. The earlier agent-run Nix check predates the final parameter-only
correction; the later owner-run root flake check described below passed with
that correction included.

Six local batch ERT tests pass. GTK and PGTK Nix checks also pass for the new
six-family suite: byte compilation, package-lint, startup smoke, startup order,
package availability and grammar runtime, plus treefmt. Tested platform is
x86_64-linux only. Compilation covers all eighteen libraries and succeeds but
still emits functional-module/third-party warnings; no warning-free or complete
interactive-configuration acceptance is claimed.

The successful agent-run command was timeout 120s nix flake check
--no-write-lock-file -L path:<selected-source-snapshot>. To include untracked
new sources without changing the project index, an ignored tmp directory held
only current tracked project files plus the three new source/check files,
excluding Git metadata, ignored/private directories and dependencies. All
sixty-nine selected files were byte-compared to the worktree after the passing
run and matched. The owner then clarified that README must describe stable
structure, usage and check contracts, not experimentation or execution results.
The temporary verification/result paragraph was removed from README; these
records remain here. Existing migration anecdotes, recipe failure symptoms and
hypothetical maintenance notes were also removed; current structure, interfaces,
dependency ownership and check contracts remain. README is excluded from
treefmt. The snapshot is reproducible from current sources,
not a durable dependency that later work must retain.

Batch ERT covers lazy interface/entry loads, named registration uniqueness and
removal, two-phase ordering/argument/return semantics, disabled user init,
early repeat calls, regular module/custom-file ordering and recursion, and
retry after failure. It does not launch interactive Emacs. Earlier fixture
failures were corrected before the passing runs; no third-party config was
loaded by the isolated scheduling tests.

## Completion and next action
Source normalization and related calls/tests/README are committed. This step
was complete with a clean project worktree at that confirmation. The prior
checkpoint preserves
the pre-normalization source context; the completion checkpoint associates the
inspected committed implementation for subsequent recovery and source review.
The later owner-run root flake check passed after the source-normalization
commit and final minimum-version parameter correction, as recorded below.
The owner requested a read-only feasibility assessment of installing lisp/ as
an independent Nix derivation while retaining Twist dependencies and wrapper.
This is a proposal, not an adopted implementation or authorization to edit code.
A source-only installation at share/emacs/site-lisp/emarccs can feed the existing
site-start load-path/require entry without depending on Emacs or Twist at build
time. Keep byte-compilation/lint as separate checks; source installation alone
does not prove compilation or provide a complete dependency closure. Runtime
smoke and scheduling tests should exercise the installed package, not silently
keep the source-directory load-path. If production byte compilation is added,
do not build with the final wrapper that already depends on Emarccs: that
creates a derivation cycle. Use a separate third-party-only build environment
or explicit compile inputs. Existing pkgs/default.nix asserts every package
subdirectory contains a MELPA recipe or override, so a local derivation needs
an explicit separate placement or a scoped change to discovery policy.
No implementation, build or test was performed for that earlier assessment.

## Completed experiment: Nixpkgs packages without Twist
The owner authorized designing and running an isolated independent flake and
bounded batch tests, maintaining memory, and assessing test-file archival.
Org is explicitly included using unmodified Nixpkgs packaging; its special
annotation does not exclude it. EPKGS.md contains 75 entries: test 69 existing
attributes and exclude only the six marked missing packages. No root-flake
migration, project staging or undo of owner changes is authorized.
The experiment lives at project tmp/nixpkgs-epkgs-experiment, with its own flake
and a minimal lock retaining the current project Nixpkgs revision. No Twist or
existing project overrides/configuration are imported. All 69 attributes were
confirmed present using the Emacs PGTK-specific package scope. It builds a
combined wrapper and individual wrappers; fresh per-package batch probes avoid
masking missing dependency declarations with unrelated explicit seeds. Checks
use a temporary HOME, controlled PATH, 30s timeout and --batch -q (site startup
retained). Attribute-to-library mapping initially differs for AUCTeX (tex-site).
Combined wrapper build succeeded with Emacs PGTK 31.1. All 69 independent
package wrappers built and passed fresh batch require probes; all 69 also
passed independent fresh loads in the combined wrapper. Org actually loads
Nixpkgs 9.8.10, below the requested 10.0-pre version; it remains included and
unmodified. Both shared-process loading orders passed, together with Org parsing,
Org-roam SQLite SELECT, PDF Tools epdfinfo page count on the one-page fixture,
and AUCTeX LaTeX-mode creation: all ten runtime observations passed. The final
72 check derivations passed, including negative controls requiring exit 1
for a deliberately missing library and for an early runtime failure followed
by successful later probes. Initial dependency-report null handling
and a negative-control grep PATH bug were harness errors corrected before the
final pass; neither was a package failure. Pre-checkpoint review also fixed
destructive reversal that could hide earlier runtime errors from the exit
oracle. The collector had checked all observations independently; all positive
results remain valid, and the new early-failure/late-success control passed.
Haskell mode still warns about a missing grammar, and Org GTD emits its v4
migration notice. Tree-sitter is available, but nix/haskell/bash/json/python
grammars were unavailable. Under isolated PATH, rg/git/diff/find/latex/sbcl
were not found; epdfinfo was not on PATH either but worked via its packaged
path. Do not equate load success with complete runtime tool/grammar propagation
or interpret PATH probes as proving absence from the whole Nix closure.
Results are observations, not full application-workflow acceptance.
At the experiment's initial inspection, owner changes included staged
flake.lock, changed lock-flake and removed local Org recipe/build overrides.
At experiment completion the owner had committed the input update
(subject: chore(flake): update flake inputs), and the root worktree was clean.
The agent did not change the project index or make that project commit. The
archive's working-input provenance refers to the initial source inspection;
this later commit is not a new test baseline or an added project parent.
Subsequent read-only review found a further owner commit switching the root
Twist Org recipe and lock source from tecosaur/dev to the official
https://github.com/bzg/org-mode.git main branch. The existing Org pre-build
version-metadata helper remains present. This is a real source change in the
root configuration, separate from the isolated experiment's unmodified
Nixpkgs Org 9.8.10. The owner subsequently supplied the complete output of a
manual root `nix flake check`: exit 0, all checks passed in about 55.4 seconds.
The output covers x86_64-linux GTK and PGTK six-family checks plus treefmt,
and includes actual dependent builds (not just evaluation), including the
GTK Org 10.0-pre derivation and its dependents. Therefore both the required
builds and the flake checks passed for the official-upstream root state.
This is owner-executed evidence, not a fresh agent-run command. Read-only
inspection still found the inspected source-switch commit at HEAD and a clean
worktree. The run omitted incompatible systems and does not prove complete
interactive startup or every configuration workflow. The independent Nixpkgs
experiment remains a separate Org 9.8.10 result.
The project worktree is currently clean. The completion archive remains
unchanged, preserving its original input and test scope.
For later configuration-package work, the owner requires explicit package
parameters through tests/default.nix and relevant tests, not ../../lisp.
Archive assessment selected the bounded experiment because its independent
inputs/tests are not recoverable from project history and support migration
reproduction. Captured definitions, lists, exact lock, fixture, scripts,
dependency inventory, structured observations and method/limits report at
archive/2026-10-21T11-42-53Z--nixpkgs-epkgs-experiment/MANIFEST.md;
byte comparisons passed. Full logs, caches and build products were not
archived. This experiment is complete; the owner has not authorized changing
the root flake to remove Twist. Future work must address Org 10.0-pre, the six
excluded packages, grammar provisioning, external tools and full-config
compatibility separately. Only x86_64-linux PGTK was tested. The owner's
special no-additional-approval authorization ends with this work.

## Known limitation and historical evidence
Extension-parameter citations have a reported preprocessing gap tracked in
[project issue 1](https://github.com/ren-lingyu/emarccs/issues/1). Its external
status was not rechecked and no fix is established here. Original historical
session execution commits remain uncertain; reconstruction claims and older
owner-run checks retain their narrower scopes. The validations above belong
to this source-normalization step and do not rewrite earlier provenance.
