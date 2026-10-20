# Emarccs architecture

## Startup and deployment
The project is an Emacs 31-targeted personal configuration. Older Emacs versions
receive a warning rather than an initialization error. Root `early-init.el`
disables package.el and sets frame/package startup defaults. Root `init.el`
resolves both `lisp/pure-emacs/` and `lisp/share/` from its own loaded file,
requires `emarccs-pemacs` first and then `emarccs-shared`. The latter orders
shared features and loads optional `custom.el` last. User customization can
therefore override module defaults without relocating user-emacs-directory.
The Home Manager flake deploys the entry files and Lisp tree to a configurable
directory; it does not yet construct a declarative package environment.

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
The packaging source explains why bootstrap, package selection and shared
behavior must be separate. Its later Nix-wrapper ordering and generated-autoload
findings are retained as source context, not claimed as implemented here.
Declarative startup checks and full grammar runtime coverage do not yet exist.
