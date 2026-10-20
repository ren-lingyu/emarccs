# Current memory

## Work entry points
Read `architecture.md` for the single-entry Nix configuration, package
interfaces, Org workflows, extension semantics and their design motivations.
Read `backlog.md` for deferred documentation work and its verified scope.
Read `reconstruction.md` when interpreting historical claims and evidence limits.
Use `git gaw status` and relevant public checks for live GAW lifecycle state.

## Uncommitted project state (pure-entry removal and lisp flattening)
Step one is complete in the reviewed working state and accepted by the owner.
The refactor and corrected batch startup-order test remain uncommitted and
staged on `main` (45 changed paths). The subsequent README reconciliation is
an unstaged edit on top of its already staged entry-removal changes.
No project commit represents the completed candidate; read the index and
README worktree rather than assuming project HEAD contains that state.

The owner clarified step one: remove the pure-emacs entry, its mechanisms and
test support; flatten `lisp/`; move early initialization there; consolidate the
old root init and shared entry into one configuration entry; update features
and related namespaces. Removing twist.nix itself remains the later objective.

Content of that state:

- Root `init.el` deleted; root `early-init.el` moved to
  `lisp/emarccs-early-init.el` (feature `emarccs-early-init`). No elisp file
  remains at the repository root.
- `lisp/pure-emacs/` (straight bootstrap) deleted, together with the twelve
  `pkgs/*/straight-register.el` recipe files.
- `lisp/share/` and `lisp/twist-emacs/` flattened into `lisp/`; the
  `emarccs-shared` namespace was replaced by `emarccs` throughout.
- `emarccs-shared.el` became `lisp/emarccs-init.el` (feature `emarccs-init`),
  which now also requires `use-package`.
- `emarccs-twist.el` and `emarccs-twist-advice-add.el` merged into
  `lisp/emarccs-bootstrap.el`, providing the startup-phase advice.
- `flake.nix` `extraSiteStartElisp` reduced to one load-path entry, one require
  and one advice-add; `elispSource` is now only `./lisp`; the startup check list
  shrank from six items to five purely because two directories merged.
- `tests/`: the startup smoke test targets `emarccs-bootstrap` / `emarccs-init`
  and dropped two now-meaningless load-path substring checks; the fake straight
  bootstrap input was removed from the byte-compile check.
- `tests/startup-order/` is now staged and wired into `tests/default.nix`.
  It now uses batch ERT and minimal generated payloads to check adapter phase
  ordering, argument forwarding and skipping configuration when init-file-user
  is nil. The owner removed the former unused interactive fixtures.
- `pkgs/default.nix` reduced its three directory predicates to two.
- `.gitignore` dropped the two root elisp whitelist entries.

Deliberate non-goals of that state: no header-comment normalization, no change
to the double-hyphen privacy scopes inside symbols, no removal of the `-twist`
suffix in output names, no touch of `locks/`, and no move to a
`pkgs/emacsPackages/<name>` plus `withPackages` layout.

## Validation status and next action
The owner ran `nix flake check` against the corrected working tree and supplied
its output: exit code 0, about 6.9 seconds, `all checks passed!` on x86_64-linux.
It built the GTK and PGTK startup-order checks and treefmt; the other checks
were satisfied without rebuilding in this invocation. Do not imply that every
check was freshly rebuilt or that omitted platforms were tested. This is
owner-executed validation with supplied output, not agent execution.

Static review found no blocking structural migration defect: all seventeen
modules are flat, filename/provide pairs agree, local requires resolve, and
renamed shared modules differ only by namespace replacement. Removed entry,
feature/path and straight bootstrap references were absent in inspected code
and configuration; upstream emacs-straight repository names are unrelated.
The old root init's paths, pure bootstrap and version warning were removed;
shared configuration and use-package setup now live in emarccs-init.
Diff whitespace checks passed.

Startup-order is an adapter unit test using --batch -Q with minimal generated
payloads, a 20-second timeout and a 3-second kill-after grace. It tests phase
ordering, alternate initializer/return-value forwarding and init-file-user=nil.
It runs the phase helper twice, explicitly unloads its fixture and cleans its
temporary paths/history. Wrapper injection remains startup-smoke's scope;
these checks do not establish full interactive personal-configuration acceptance.

Two earlier failures are superseded: the interactive test timed out, and the
agent's first isolation fix failed a global features-list identity assertion.
Binding copies of features/load-history did not establish isolation, and normal
lazy dependency loads make global-list identity an unsuitable assertion.
Explicit fixture cleanup replaced it; the corrected owner-run check now passes.

The owner regards pure-emacs entry/mechanism/test-support removal, Lisp
flattening, entry consolidation and namespace migration as basically complete.
Removing twist.nix is the subsequent objective and remains unstarted here.
README reconciliation is now complete against the current worktree: the
structure includes lib, package assertions and startup-order; all five check
families and treefmt have explicit scopes; input, scope.overrideAttrs and
scope.executablePackages have separate responsibilities. Removed superchat
and unattributed old build claims were replaced with inspected current package
adaptations and the supplied owner-run flake result. The -q example and
startup delegation description were corrected. No builds or formatters were
run for this documentation edit; README is excluded by treefmt. Read-only diff
validation passed, and project staging was not changed by the agent.

This checkpoint associates the pre-removal project HEAD as a non-first parent:
that exact commit supplies the old pure-emacs entry, bootstrap/recipes and
split Lisp structure needed to explain the removal and its comparisons.
It is the historical context for this work record, not a claim that the parent
contains the completed refactor or is the tree on which the owner's successful
check ran. It was inspected directly and used as the staged-diff baseline.
The removed mechanisms remain available there to interpret this work record.

Next action: await the owner's next task. Step one and its README are ready
for project review/commit by the owner; further twist removal has not been
started or authorized here. The current request authorizes a single GAW
checkpoint consolidating these memory updates, not project index/history
mutation, builds or tests.

## Known limitation and validation boundary
Extension-parameter citations have a reported preprocessing gap tracked in
[project issue 1](https://github.com/ren-lingyu/emarccs/issues/1). No fix or
complete parameter citation support is established by this memory; the issue's
current external status has not been rechecked.

Project knowledge comes from static inspection, recovered decision summaries
and attributed historical checks. No Nix/Emacs execution was performed by the
agent during reconstruction or this review; owner-run current-platform
validation is recorded above. Original historical session execution commits
remain uncertain. Before implementation, check current behavior and permissions
rather than treating historical reports as fresh validation.
