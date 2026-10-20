# Current memory

The represented package interface distinguishes derivation overrideAttrs from
runtime executable contributions. Package-local executable declarations replace
the global flake list, and structural assertions protect recipe pairing,
directory contents and package-list membership. See `architecture.md`.

The extension registry adds exercise/proof/solution kinds. pdf-tools is selected,
but its later native server build and viewer integration are outside this state.

Next reconcile the current main tip: generic Emacs attributes, typed context,
separate nixpkgs lib/project llib, formatter checks, language integrations and
compiler fixes. Then verify all retained source tips and remove clean temporary
aux worktrees while keeping their branches. No project tests or builds are run
by this memory task; see `reconstruction.md` for evidence limits.
