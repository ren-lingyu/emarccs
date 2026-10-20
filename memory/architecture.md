# Emarccs architecture

## Purpose and initialization
Personal Emacs configuration targeting Emacs 31+. Pure startup warns on older
versions; a warning is not a compatibility guarantee. Root `init.el` locates
source-relative pure/shared load paths, requires `emarccs-pemacs` then
`emarccs-shared`. Optional custom.el is loaded last by the shared entry.

`early-init.el` disables package.el startup. Persistent frame defaults are
separate from first-frame bootstrap colors; theme configuration owns lasting
colors. Graphical font sizing prefers a nominal 4 mm face parameter when
physical dimensions are valid, accepting list or dotted-pair mm-size data,
then falls back to the smaller pixel ratio against 1920x1080 at height 110.
These are font parameters, not measured glyph dimensions.

## Dual package ownership
`lisp/pure-emacs/` owns straight bootstrap, defaults and use-package setup.
It discovers `pkgs/*/straight-register.el` relative to the source file and
registers recipe forms, including explicit built-in registrations.
A missing straight bootstrap can synchronously access the network. Historical
manual provisioning of the full straight repository is not automated fresh
installation acceptance.

`lisp/share/` owns editor and workflow behavior used by either entry.
`lisp/twist-emacs/` adapts prebuilt Nix startup. The flake supplies load paths
with eval-and-compile and renders advice through nix-to-lisp. Emacs 31's native
loader boundary preserves store early-init, real user early-init, shared config
and real user init ordering. Nil init-file-user skips wrapper configuration,
including --no-init-file. Do not reset user-emacs-directory to test this behavior.
The advice parameter was renamed to avoid shadowing Emacs' early-init-file.

The flake uses Twist makeEnv with explicit package seeds and locked dependency
closure, not blanket alwaysEnsure or parsing real init.el for :ensure.
Installed packages do not automatically enable their configurations.
Native compilation ahead is enabled. GTK/PGTK packages now use generic
`pkgs.emacs-gtk` and `pkgs.emacs-pgtk`, sharing `locks/emacs`. Per-variant
packages, lock/update apps, checks and same-platform overlays derive from
common context. This replaces the former Home Manager file-deployment interface.

## Nix interfaces and package adaptation
Flake-parts `config.context` is a typed function result with raw elispkgs and
nested variant package/lockDir options. It replaces the old flake.context output.
This centralizes repeated inputs for packages, apps and checks. Complete original
debate over alternative module structures is not recoverable.
Nixpkgs helpers are `lib`; project helpers are `llib`, instantiated through
`self.lib { inherit lib; }`. `lib/default.nix` receives nixpkgs lib rather than
capturing pkgs. Generated variant names/configurations and unique-source-line
lookup are reusable helper responsibilities.

`pkgs/default.nix` owns explicit packages, recipe discovery and override assembly.
Local copied MELPA recipes outrank MELPA, GNU and NonGNU registries. Files are
renamed from melpa-recipe.el to package names. Copying regular files addresses
the historically reproduced reader filter that discarded symlink entries.
This version-specific discovery constraint is distinct from MELPA source-boundary
restrictions on links outside a source repository. Do not generalize it into
a rejection of all symlinks or assume an upstream Nix-native registry exists.
Savannah input and registry URLs are rewritten through the HTTPS mirror.

Input overrides own recipe/package metadata and Elisp dependency edges.
`scope.overrideAttrs` owns native derivation changes; `scope.executablePackages`
contributes runtime tools, aggregated and deduplicated with inherited tools.
Dired owns coreutils, search packages own search tools, org-texmacs owns the
font-enabled TeXmacs executable. SLY requests sbcl by name; no package-local
SBCL executable contribution is established by this tree.
Directory assertions require paired straight/MELPA recipes, a recipe pair or
override in package directories, and recipe-defined packages in the explicit
list. Override-only built-ins remain valid.

Important adaptations include Org fork version metadata generation with an
exact Emacs binary; explicit AUCTeX manual builds with native TeX/Perl/Git;
citar's cl-lib autoload prerequisite; package-specific writable HOME needs;
and laas/math-symbol-lists dependency metadata. The company source patch corrects
Texinfo example placement for the updated locked package. pdf-tools builds native
epdfinfo with required native/development inputs and exposes it to the package.
The superseded string-context rendering workaround and placeholder AUCTeX manuals
are historical experiments, not current design.

## Shared behavior and workflow boundaries
Load order is basic, help, theme, Org, TeX, completion/snippets, Lisp, Org-roam,
organization/citation, LaTeX preview, feed, org-roam-blog and debug, then custom.
Changing this order can change initialization semantics.

Completion/navigation combines Consult, Vertico, Orderless, Marginalia and
Embark. Dirvish, structural highlighting, large-file support, whitespace cleanup
and margin diff-hl serve editing. Koishi setup and Doom modeline replace the
former multi-theme switcher. Common Lisp uses SLY/SBCL; Haskell Tree-sitter mode
uses Eglot. PDF files use pdf-view-mode and themed rendering. Expanded snippets
offer left/right delimiters alongside ab variants. Package availability does
not prove a language server, external executable or live workflow is configured.

Org owns capture, agenda/GTD, export and date helpers, with BibLaTeX for LaTeX
citations and a corrected bookmark-default-file. GTD uses its command center
and a complete done-state mapping instead of the earlier custom ID advice.
Org-roam owns database/autosync, capture, timestamps, post queries and native
forward-link navigation; consult-org-roam was removed.
Organization registries and org-roam-include replace legacy flat organization
settings. The organization module owns Citar/Citar-Embark and declarative Citar
literature backend fields with bibliography support. The handwritten provider
is gone; Citar-Org-Roam remains declared but disabled. Citar waits for Org and
Org-roam to avoid the earlier unbound-directory failure.

Publishing orchestration belongs to external org-roam-blog. The local module
owns site presentation, content groups, roots, export bindings, static assets
and article/sitemap renderers. Old native publishing advice and the local
after-save publication hook were removed. External package behavior is not
independently audited by reading this configuration.
The former orgraph aggregate is gone: TeX owns export tools, preview owns preview,
and Org-roam owns date/post-query behavior. Org Element is required at use sites.
Public/private helper ownership follows provided features and domain, using
one/two hyphens respectively; underscore lexical locals are a separate convention.
The former AI module and unused package definitions are removed.

## Extension-block semantics
The project-local layer accepts `#+begin_ext KIND :KEY VALUE`, avoiding collision
with native block names such as example. Native Org special-block types and raw
type/parameters are preserved; normalization adds `:extension-kind` and validated
`:extension-parameters`. Registry spelling is canonical with case-insensitive
lookup; unknown, duplicate or valueless parameters are errors.
Values remain source-form Org secondary strings until backend export.
HTML/LaTeX can lower to KIND or preserve the distinct org-extension-block export
namespace; local configuration preserves it. Source naming, normalized semantics
and backend output have separate responsibilities. HTML lowers a copied node;
LaTeX parameter export performs math wrapping and rejects conflicting ATTR_LATEX
options. Advice supports delayed exporter activation and feature unload cleanup.
Kinds include reply, mathematical statements, exercise/exercise*, proof and
solution. This is not a new native Org AST element type.

Reference material reports that citations inside parameters can miss document-wide
citation preprocessing because synthetic secondary AST is parsed during block
transcoding. No corresponding fix is established by this reconstruction; do not
claim complete parameter citation support. Reassess the export pipeline before
changing it.

## Validation and repository boundaries
treesit-auto receives a package-local patch using unique-source-anchor lookup.
It adds the aggregate with-all-grammars library path instead of copying individual
parsers or maintaining a shortlist. Unique exact matching is not fuzzy patching.
Four project check families cover independent byte compilation, startup injection,
library availability and complete produced-grammar loadability. Compilation loads
package autoloads, fakes local feature presence and uses disposable destinations;
it is not full module execution. Grammar checks enumerate actual output libraries,
test language availability and create parsers with diagnostic symbol candidates.
They do not prove real-source parsing, modes, font locking or indentation.
Stale dtd/ocaml-interface/tsx aliases were removed when native symbols changed,
and patch hunk length was corrected; the final reported pass came from the owner.
Treefmt/nixfmt also supplies a formatter and flake check.

No Nix build or Emacs runtime suite was executed during memory reconstruction.
Historical source probes and owner reports retain their narrower scopes.
README still names emacs31 package attributes, lists only two check families
and mentions removed package details; use inspected source for these facts.
The inverted ignore whitelist requires explicit inclusion of new tracked files.
Nested Twist experiments, scratch/backup directories, runtime notes/databases
and private identifiers are not the tracked project architecture.
