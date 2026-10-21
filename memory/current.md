# Current memory

## Work entry points
Read architecture.md for initialization, package ownership, Nix interfaces and
Org workflows; backlog.md for deferred work; reconstruction.md for historical
evidence limits. Use public GAW status/check for live lifecycle state.

## Current step: Elisp source-package normalization
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
reverted. Diff checks passed; the full Nix run below predates this final
parameter-only correction, which has not been rebuilt.

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
The source-normalization suite was not rerun after the owner committed.
The final Nix minimum-version
parameter adjustment still has only static verification, as described above.
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
Current owner worktree changes include staged flake.lock, changed lock-flake
and removed local Org recipe/build overrides; do not alter them.
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
