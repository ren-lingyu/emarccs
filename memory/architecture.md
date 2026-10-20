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
organization/citation integration, LaTeX preview, feed, AI, native publishing and
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
Reusable functions now live in `lib/default.nix`, instantiated with pkgs.
The flake's context function separates package/variant data from reusable helpers;
concatMapEmacsTwists supplies the generated name and configuration to consumers.
Package overrides receive project helpers, while nixpkgs lib remains available
through pkgs. Org's recipe preBuild uses an exact Emacs executable path.
Shared editing now enables nix-ts-mode and managed grammar integration through
a package-local treesit-auto patch. Unique-anchor lookup locates the patch
insertion point. The package now uses with-all-grammars rather than a shortlist.
Runtime checks enumerate produced libtree-sitter shared objects, verify language
availability and create parsers; failures report candidate initialization symbols.
Special aliases handle mismatched output names. Later native outputs made the
dtd/xml, ocaml-interface/ocaml and tsx/typescript aliases stale; those three
were removed and the generated patch hunk length corrected. The owner reported
tests passing after correction; the agent did not rerun a full check.
These validate loadability, not
major modes, font locking, indentation or correctness on real source corpora.
Input metadata and native derivation adjustments stay distinct.
Startup smoke checks generated structure;
package-availability smoke locates libraries rather than requiring all packages.
Historical GUI checks support ordering in three modes, but are not fresh tests.

## Org knowledge workflow
The tecosaur Org fork uses recipe pre-build version metadata. Org owns capture,
agenda/GTD, export and citation processor preferences. The runtime Org directory
holds notes and databases outside this source repository.
Org-roam supplies database/autosync, capture, timestamps and link navigation.
org-roam-include and organization registries replace legacy flat settings.
The organization module owns Citar, Citar-Embark, Citar-Org-Roam and a private
Citar-backed literature provider. The provider's API calls use Citar directly;
the bridge remains configured for workflow stability. Citar waits for both Org
and Org-roam, correcting an early unbound-directory failure. Consult forward-link
selection belongs in the roam module, not citation integration.

Publishing infrastructure now belongs to the external org-roam-blog package.
The local `emarccs-shared-org-roam-blog.el` module supplies content groups,
runtime source/output roots, published-time policy, export bindings, static
assets and custom article/sitemap renderers. The old native publishing module
and its global file-selection advice/after-save publication hook were removed.
Do not infer that the old hook remains active merely because source history
describes it. The shared entry now requires the renamed provided feature.
The repository owns personal presentation; the external package owns reusable
publishing orchestration. Its implementation is not independently audited here.

The orgraph aggregate remains removed: TeX owns export tooling, preview owns
preview behavior and Org-roam owns timestamp/post queries. org-directory is
the shared runtime root. The Docker backend and redundant package-loading glue
are absent. Org Element is loaded at use sites.
Public helpers use their provided-feature prefix; private ones add a double
hyphen. Ownership follows domain/API, with public cross-file interfaces.
The earlier seven-module naming pass excluded native publishing; its replacement
now supplies project-prefixed site helpers.
Editing also adds trailing-whitespace cleanup and margin-based diff-hl.

## Evidence and boundaries
The inverted Git ignore whitelist controls tracked files. Runtime notes,
personal identifiers and local tool paths are not reproduced in memory.
Static source/entry inspection establishes these responsibilities. Display
and module-contract source reports provide narrower GUI/stub evidence:
font checks reported 114/110/176, while the structural session does not finish
a full real-config startup test. The owner reported manual Org smoke checks
without blockers after namespacing. The proposed ERT suite was neither created
nor run; missing-description link handling and other suggested targets are
unverified suggestions rather than established fixes. No fresh build or runtime
test was run.
The packaging source reports successful bounded package/module/preview and
fixture-database probes, with skips and known API drifts. Live note moves/deletes
were deferred. A blank pure startup traced to synchronous bootstrap fetching;
copying bootstrap.el alone was insufficient. The owner supplied the complete
straight repository and reported package build progress, not automated fresh
installation acceptance. Upstream reproductions explain selected workarounds;
external issue status is not checked now. Grammar library discovery is not
proof of load-symbol compatibility. The runtime suite makes that distinction
executable, but source reports and the inspected suite are not a fresh pass.
