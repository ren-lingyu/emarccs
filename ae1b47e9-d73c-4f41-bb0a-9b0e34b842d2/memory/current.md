# Dual-entry packaging discovery

## Scope and stable startup
Recovered from the full long July packaging source, distinguishing nested
Twist experiments from main. Shared config supports straight and locked explicit
Nix packages; no blanket :ensure policy. Emacs 31 advice runs store early-init,
then real user early-init, and shared configuration before the user's init.
--no-init-file skips wrapper configuration. Source GUI probes cover these cases;
batch visibility probes do not establish GUI execution. Generated citar
autoloads need cl-lib, supplied by a preBuild autoload cookie.

## Nix/Elisp interface and checks
The flake owns load-path and feature derivation. Small adapter functions return
advice closures; avoid global constants used solely as glue. eval-and-compile
makes compile-time paths available. Nix-to-Lisp rendering initially lost string
context and a store path was missing in the sandbox. A temporary raw-path helper
was superseded after an upstream fix and owner lock update; ordinary rendering
was restored. The workaround is not a permanent interface requirement.
Expose GTK and PGTK variants with shared major-version locks, per-variant lock
and update apps, and usable metadata descriptions. Flake-parts coordinates
outputs. Startup smoke verifies site-start structure; availability smoke uses
locate-library, not requiring every package.

## Recipe and native-tool corrections
MELPA registry discovery in the reproduced setup only accepted regular entries.
A symlink farm failed; copying renamed recipes into a derivation worked.
This is a concrete registry behavior, not a universal ban on symlink registries.
Prioritize local recipes over MELPA over ELPA git. ELPA git URL parsing failed
for some aliases; explicit org-edna and queue mirror recipes supplied fallbacks.

AUCTeX's final approach injects Git, Perl and TeX tools, patches a ChangeLog path
that assumes a Git checkout, and explicitly builds/installs auctex and preview
manuals. A shell local named info had overwritten the output variable; rename
it rather than replacing documentation with empty placeholders.
Writable HOME overrides remain package-specific. Keep Elisp dependency edges
such as laas/math-symbol-lists out of native executable declarations.

## Next action and evidence
Finalize reproducible upstream reports and main handoff. Historical functional
probes include skipped/deferred cases; no new runtime or build validation occurs.
