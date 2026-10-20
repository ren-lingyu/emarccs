# Dual-entry packaging discovery

## Source and adopted foundation
The full long July packaging horizon was surveyed, including nested Twist work.
It supports dual straight/Nix package ownership with shared configuration.
Reject broad :ensure rewrites and alwaysEnsure; explicit locked package seeds
plus dependency closure avoid fetching built-ins. The tecosaur Org recipe
generates version metadata. Native tools are separate from Elisp dependencies.
Historical probes cover packages, modules, API drifts, preview and fixture
databases, not every real user workflow. No checks are rerun in reconstruction.

## Configured startup contract
A direct site-start require of shared configuration was too early relative to
autoload initialization and init-file-user. Batch mode cannot prove GUI
ordering because its initialization conditions differ.
Emacs 31 startup integration targets the native user-init boundary with advice:
store early-init precedes real user early-init; shared configuration precedes
the user's init overlay. When init-file-user is nil, including --no-init-file,
the wrapper skips configuration. The owner rejected changing user-emacs-directory.
The wrapper supplies load-path; pure bootstrap and shared behavior stay separate.

A citar generated autoload uses cl-defsubst and needs cl-lib. Attempts to fix
postBuild or a build command input were ineffective. Adding a cl-lib autoload
cookie in preBuild addressed the generated-autoload failure.
The source reports three GUI cases: overlay sees shared configuration,
no-user-config still runs the wrapper, and --no-init-file skips it.
Batch locate-library checks alone establish package visibility.

## Package/validation limits
Writable HOME is narrowly needed by selected package builds. laas requires
math-symbol-lists. The AUCTeX documentation workaround still needs a complete
native build policy. Earlier package/module/preview suites reported no failures
within their stated scopes; real note mutation remained deferred.

## Next action
Complete Nix-to-Lisp generation, variants/checks and upstream workarounds before
the source's final main handoff. Do not read later source capabilities into an
earlier pure/shared main snapshot.
