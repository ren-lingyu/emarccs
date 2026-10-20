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

## Deferred architecture change

Removing twist.nix in favour of packaging each Emacs package under
`pkgs/emacsPackages/<name>` and composing Emacs with `withPackages` is a stated
but unstarted objective. The flattening above deliberately locked the current
state into the wrapper-injection route: the configuration is loaded by an
advice, not through Emacs' native `init.el` / `early-init.el` filenames, so
using the repository directly as `user-emacs-directory` no longer works.
Reopening that route is a design decision for the future change, not a bug.
