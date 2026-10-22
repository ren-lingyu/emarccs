# Backlog

## Resolve the remaining naming task before any further layout change

`TODO.md` (Git-ignored, therefore worktree-only) still targets `my/`-prefixed
and other non-namespaced globals. Its target names were mechanically rewritten
to the `emarccs-*` namespace, and its stale `emarccs-blog-publish` section was
retargeted to `emarccs-org-roam-blog`, which is the module that actually exists.
That retargeting is a naming decision recorded here, not a verified rename plan.

Deferred alongside it: the symbols under `emarccs--org-roam-blog-*` read as
private to `emarccs` while their feature is `emarccs-org-roam-blog`. The owner
decided not to touch them, because the observed double hyphen marks two
different privacy scopes and flattening it would change meaning. Do not treat
that as an oversight and do not fix it without a new decision.

## Remaining migration follow-up

The Nixpkgs emacsPackagesFor/withPackages migration is committed and its
reconnected tests pass on x86_64-linux; see current.md and the committed
migration section in architecture.md. The older description of this work as
unstarted is superseded. Inputs and README are deliberately retained unchanged
for now. Library extraction is a future objective: lib/packages.nix intentionally includes
generic logic that may have no local callers. Evaluate it as a cross-repository
library; ~/nixos/pkgs/lib/ is an owner-provided comparison reference. Its
packages.nix matched the Emarccs copy in a read-only comparison before later
discovery/interface changes; do not assume the copies remain synchronized.
Unused flake interface glue remains deferred separately. These follow-ups are
not permission to edit them.
