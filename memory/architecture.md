# Emarccs architecture

## Startup and deployment
The project is an Emacs 31-targeted personal configuration. Older Emacs versions
receive a warning rather than an initialization error. Root `early-init.el`
disables package.el and sets frame/package startup defaults. Root `init.el`
resolves both `lisp/pure-emacs/` and `lisp/share/` from its own loaded file,
requires `emarccs-pemacs` first and then `emarccs-shared`. The latter orders
shared features and loads optional `custom.el` last. User customization can
therefore override module defaults without relocating user-emacs-directory.
The flake now builds declarative Twist environments rather than exposing the
earlier Home Manager file deployment interface. GTK/PGTK Emacs 31 variants share
`locks/emacs`; packages, lock/update apps, checks and same-platform overlays
are generated with flake-parts. Native compilation ahead is enabled.

## Ownership and capabilities
Pure startup now owns straight bootstrap, defaults and use-package setup in
`emarccs-pemacs-straight.el`. It discovers `pkgs/*/straight-register.el` recipes
relative to its own file, reads each recipe form and registers it. Empty recipe
files are errors; dired and dired-x are registered as built-ins.
Shared modules retain behavior rather than package-source declarations.
This makes the shared entry usable by a separately supplied package environment
without running pure bootstrap. Missing straight bootstrap may still download
synchronously; offline fresh-start acceptance has not been demonstrated.
Module order is basic, help, theme, Org, TeX, completion/snippets, Org-roam,
citation integration, LaTeX preview, feed, AI, native publishing, orgraph and
debugging, followed by customization. Completion uses Consult/Vertico/Orderless/
Marginalia/Embark; editing includes Dirvish, language modes and Tree-sitter
conveniences. Presence of a package does not prove every feature is active.

Graphical display sizing prefers a nominal 4 mm face-height calculation when
physical monitor dimensions are valid. Both list and dotted-pair mm-size data
are accepted. Fallback scales height 110 by the smaller pixel ratio against
1920 by 1080; terminal/daemon display conditions remain significant.
This is a nominal font parameter, not measured glyph dimensions.

## Declarative environment
`pkgs/default.nix` owns explicit package names, copied local MELPA recipes and
input/scope overrides. Registry priority is local, MELPA, GNU then NonGNU.
No blanket alwaysEnsure is used. Elisp dependencies and native build tools have
different owners. Selected package builds need writable HOME; AUCTeX explicitly
builds its manuals with Git/Perl/TeX support rather than generic subordinate
Texinfo scanning. Org's recipe produces version metadata; citar autoloads
receive cl-lib in preBuild. Explicit recipes handle selected ELPA git aliases.

The flake renders site-start forms through nix-to-lisp, adding adapter/shared
load paths with eval-and-compile. The adapter returns advice around Emacs 31's
native user-init loader: store early-init, user early-init, shared configuration,
then user init. With nil init-file-user, wrapper configuration is skipped.
The user's Emacs directory remains their runtime state root.
Flake helpers still live inline here. Startup smoke checks generated structure;
package-availability smoke locates libraries rather than requiring all packages.
Historical GUI checks support ordering in three modes, but are not fresh tests.

## Org knowledge workflow
The tecosaur Org fork uses recipe pre-build version metadata. Org owns capture,
agenda/GTD, export and citation processor preferences. The runtime Org directory
holds notes and databases outside this source repository.
Org-roam supplies database/autosync, capture and organization. Organization
settings have migrated away from slash-style variable names, but the later
registry/include API is not part of this represented state.
Citation-node and preview integrations remain separate modules. Package loading
order supplies implicit dependencies.

Native Org publishing owns HTML metadata, sitemap/index handling, static assets
and site customization. Database-aware file selection queries file-level
Org-roam nodes by tags and path scope and includes generated sitemap/index
paths. A legacy file generator remaining defined is not the active selection
path. The orgraph aggregate still connects export/preview, bibliography roots,
timestamps, selected-note automatic publication and package loading. Its
cross-module coupling is a future ownership problem, not yet dismantled.

## Evidence and boundaries
The inverted Git ignore whitelist controls tracked files. Runtime notes,
personal identifiers and local tool paths are not reproduced in memory.
Static source/entry inspection establishes these responsibilities. Display
and module-contract source reports provide narrower GUI/stub evidence:
font checks reported 114/110/176, while the structural session does not finish
a full real-config startup test. No fresh build or runtime test was run.
The packaging source reports successful bounded package/module/preview and
fixture-database probes, with skips and known API drifts. Live note moves/deletes
were deferred. A blank pure startup traced to synchronous bootstrap fetching;
copying bootstrap.el alone was insufficient. The owner supplied the complete
straight repository and reported package build progress, not automated fresh
installation acceptance. Upstream reproductions explain selected workarounds;
external issue status is not checked now. Full grammar runtime coverage does
not yet belong to this represented state.
