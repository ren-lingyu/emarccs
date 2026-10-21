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
is complete; no project changes are pending. The prior checkpoint preserves
the pre-normalization source context; the completion checkpoint associates the
inspected committed implementation for subsequent recovery and source review.
No tests were rerun after the owner committed. The final Nix minimum-version
parameter adjustment still has only static verification, as described above.
Await the owner's next objective rather than extending this intermediate step.
The broader twist.nix removal remains deferred and is not authorized here.

## Known limitation and historical evidence
Extension-parameter citations have a reported preprocessing gap tracked in
[project issue 1](https://github.com/ren-lingyu/emarccs/issues/1). Its external
status was not rechecked and no fix is established here. Original historical
session execution commits remain uncertain; reconstruction claims and older
owner-run checks retain their narrower scopes. The validations above belong
to this source-normalization step and do not rewrite earlier provenance.
