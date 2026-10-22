# Emarccs architecture

## Working-tree transition notice
The staged 2026-10-22 migration supersedes the committed Twist architecture
below: Nixpkgs emacsPackagesFor/withPackages now consumes a local emarccs
trivialBuild package at pkgs/emacsPackages/emarccs, with local dependency
overlays. The wrapper's injected site-start owns early initialization and a
before-init-hook registration; emarccs.el only requires interface definitions.
Old bootstrap/advice scheduling, root lisp/, Twist runtime integration and
lock/update apps are removed in the working tree; inputs remain. Tests have
now been adapted and reconnected for all three Emacs outputs through explicit
configurationPackage/grammarPackage parameters. Sources come from the package's
src; runtime/ERT use installed libraries and actual generated site-start forms.
The new 19-check flake run passed on x86_64-linux, including seven ERT cases per
variant, 17-library lint, 75 dependency availability and 334 grammar parsers.
See current.md for evidence, preserved lint exemptions and verification limits.
The migration and test edits are still uncommitted. The remaining sections
are the previously committed Twist baseline, retained as historical context;
where they conflict, this notice and current.md describe the working tree.

## Purpose and initialization
Personal configuration targeting Emacs 31.1+, organized as an Elisp source
package under the existing flat lisp/ directory. Source normalization does
not add a Nix derivation, distribution archive or complete Package-Requires
closure. Third-party packages still come from the Twist wrapper; Emarccs
itself is loaded directly from source. No root native init.el/early-init.el
entry or straight bootstrap remains.

emarccs.el is the sole startup registration owner. Requiring it loads the
bootstrap/early-init/init interface definitions and installs one named
emarccs-startup :before advice on startup--load-user-init-file. It does not
load Org, AUCTeX or the functional configuration modules. Reloading the entry
checks the advice name to avoid stacking; the name supports lookup/removal.

emarccs-bootstrap.el only defines the adapter. Non-nil init-file-user allows
emarccs-initialize-early in the early phase and emarccs-initialize in the
load-defaults phase. Native :before advice preserves original arguments,
execution and return values. The flake's generated site-start only adds lisp/
to load-path with eval-and-compile and requires emarccs; it no longer selects
initializers, embeds early-init paths or registers the advice itself.

The early initializer preserves existing frame/package settings and applies
them once. The regular initializer requires use-package, disables automatic
ensuring, requires functional modules in their established order and loads
optional custom.el last. It prevents recursive initialization, skips successful
repeat calls and marks completion only after success. Functional module hooks
and advice remain local to those modules. Actual macro users explicitly require
use-package at compile time rather than depending on compilation order.

Persistent frame defaults are separate from first-frame bootstrap colors;
theme configuration owns lasting colors. Graphical font sizing prefers a
nominal 4 mm face parameter when physical dimensions are valid, accepting
list or dotted-pair mm-size data, then falls back to the smaller pixel ratio
against 1920x1080 at height 110. These are font parameters, not measured glyph
dimensions.

## Package ownership and startup adapter
Files/features use emarccs-<name>, with emarccs.el providing emarccs as the main
library. The double hyphen in the private extension module and inside symbols
such as emarccs--org-extension-block--source-namespace marks distinct privacy
scopes; it is not planned for flattening. The former pure-emacs/straight entry,
recipe convention and split shared/twist source directories were removed in
the preceding accepted step, not left unmaintained.

Loading interface definitions, installing startup scheduling and executing
configuration are separate responsibilities. Future hooks or a startup.el
patch should change the entry's registration logic while retaining initializer
interfaces; neither alternative is introduced now. Do not reset
user-emacs-directory to emulate the startup boundary.

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
This centralizes repeated inputs for packages, apps and checks. The owner's
retrospective clarification identifies the broader goal: keep configuration data
within an explicit module system wherever practical, instead of maintaining a
parallel non-module configuration source. Prior NixOS practice may have informed
this choice. Options/submodules express ownership and constraints; ordinary
functions still transform data and construct outputs. This is an architectural
preference, not a requirement to turn every local value or function into an option.
Nixpkgs helpers are `lib`; project helpers are `llib`, instantiated through
`self.lib { inherit lib; }`. `lib/default.nix` receives nixpkgs lib rather than
capturing pkgs. Generated variant names/configurations and unique-source-line
lookup are reusable helper responsibilities. The lib/llib distinction clarifies
helper ownership; it supports the configuration-data goal rather than defining it.

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
Recovered user decisions favor local consumer ownership: each package may declare
the same tool independently, and the assembly layer uses lib.unique to deduplicate.
Consumers should not need to coordinate a manually deduplicated global tool list.
Runtime environment tools belong beside derivation adjustments in scope, not
inside an individual Elisp derivation's attributes.
Dired owns coreutils, search packages own search tools, org-texmacs owns the
font-enabled TeXmacs executable. SLY requests sbcl by name; no package-local
SBCL executable contribution is established by this tree.
Directory assertions require at least a MELPA recipe or an override in each
package directory, and recipe-defined packages in the explicit list.
Override-only built-ins remain valid.
The owner clarified that directory/framework constraints should be enforced
during relevant Nix evaluation, before invalid structure reaches package builds
or runtime. The generic predicate evaluator receives the root, packages and
rules from its caller; recipe filenames are policy in pkgs/default.nix rather
than hardcoded validator knowledge. Because evaluation is lazy, assertions run
when the asserted expression is evaluated, not merely when flake.nix is parsed.

The root Twist Org recipe and lock now select the official bzg/org-mode main
branch, replacing tecosaur/dev. The existing pre-build version-metadata helper
still invokes an exact Emacs binary. The owner supplied a successful root
nix flake check after this switch: x86_64-linux GTK/PGTK checks and their
required builds passed, with an Org 10.0-pre derivation visible in the build
output. The separate independent Nixpkgs experiment used Org 9.8.10; its result
must not be substituted for this owner-run upstream-source validation.
Important adaptations also include explicit AUCTeX manual builds with native TeX/Perl/Git;
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

Publishing orchestration belongs to external org-roam-blog. Recovered historical
decisions describe extraction as a responsibility and side-effect boundary:
Emarccs configures the site, org-roam-organize manages nodes/literature, and the
publishing package orchestrates output. The local module owns presentation,
content groups, roots, export bindings, static assets and article/sitemap
renderers. Old native publishing advice and the local after-save hook were removed.

The recovered publishing requirements make the Org-roam DB the sole source of
publishable level-0 nodes, without a directory-scan fallback. Handwritten index
and about pages remain legitimate nodes. Canonical output should preserve
source-relative structure for existing links; generated public entries/redirects
need not determine canonical content paths. Node metadata comes from the DB,
while position-sensitive #+INDEX annotations belong to the export parse tree.
Plan output and detect target collisions before writing.
Publishing should leave no permanent global project-list changes, advice, export
filters or save hooks. This scoped operation must still run normal Org Export
hooks/filters, including citation preprocessing. Git deployment remains outside
publishing orchestration. These are recovered design requirements, not a claim
that every external-package behavior has been independently verified here.
The former orgraph aggregate is gone: TeX owns export tools, preview owns preview,
and Org-roam owns date/post-query behavior. Org Element is required at use sites.
Public/private helper ownership follows provided features and domain, using
one/two hyphens respectively; underscore lexical locals are a separate convention.
The former AI module and unused package definitions are removed.

## Extension-block semantics
The project-local layer accepts `#+begin_ext KIND :KEY VALUE`. Recovered user
decisions chose one namespace to avoid native block-name collisions such as
example while keeping Org documents canonical and leaving the native parser
unchanged. Native special-block types and raw type/parameters are preserved;
normalization adds `:extension-kind` and validated `:extension-parameters`.
Registry spelling is canonical with case-insensitive
lookup; unknown, duplicate or valueless parameters are errors.
Values remain source-form Org secondary strings until backend export.
HTML/LaTeX can lower to KIND or preserve the distinct org-extension-block export
namespace; local configuration preserves it. The stable writing syntax is
deliberately independent of a backend's representation name. preserve-namespace
changes export lowering only, not canonical source or normalized AST semantics.
Source naming, normalized semantics and backend output have separate
responsibilities. HTML lowers a copied node;
LaTeX parameter export performs math wrapping and rejects conflicting ATTR_LATEX
options. Advice supports delayed exporter activation and feature unload cleanup.
Kinds include reply, mathematical statements, exercise/exercise*, proof and
solution. This is not a new native Org AST element type.

Recovered user reports describe ordinary inline markup and links working in
HTML/LaTeX secondary-string export; this is limited historical evidence, not
acceptance of every secondary syntax.
Reference material reports that citations inside parameters can miss document-wide
citation preprocessing because synthetic secondary AST is parsed during block
transcoding. No corresponding fix is established by this reconstruction; do not
claim complete parameter citation support. Reassess the export pipeline before
changing it.

## Validation and repository boundaries
treesit-auto receives a package-local patch using unique-source-anchor lookup.
It adds the aggregate with-all-grammars library path instead of copying individual
parsers or maintaining a shortlist. Unique exact matching is not fuzzy patching.
Six project check families cover independent byte compilation, startup
injection, adapter/initializer behavior, source package lint, library
availability and produced-grammar loadability. Compilation loads package
autoloads, supplies local feature placeholders and uses disposable output
files; it does not initialize the complete configuration. Its input remains
lisp/ and includes all eighteen source libraries. Existing warnings are not
fatal; passing byte compilation is not a warning-free claim.

Startup smoke greps the wrapper's generated site-start for the source path
and main entry, then checks that emarccs was loaded, its named advice and
initializer interfaces exist, and batch startup has not run configuration.
Startup-order uses bounded --batch -Q ERT with substitutes to check lazy entry
loading, unique/removable registration, phase ordering, native parameter/return
semantics, disabled user initialization, repeat/recursive initialization and
failure retry. No interactive session or complete personal configuration is
required by that test.

Package-lint uses independent Nixpkgs test tooling and the public buffer API,
with emarccs.el as main file. It checks all lisp libraries. The owner approved
only reserved-key and with-eval-after-load diagnostics in functional personal
configuration modules as explicit, printed exemptions; every other diagnostic
fails and the four initialization/entry libraries are strict. This intermediate
source-package stage declares only verified metadata, not a full independently
installable third-party dependency closure.

Grammar checks enumerate actual output libraries, test language availability
and create parsers with diagnostic symbol candidates. They do not prove real
source parsing, modes, font locking or indentation. All six GTK/PGTK families
and treefmt passed in the agent-run x86_64-linux selected-source-snapshot check
for the source-normalization implementation before final README cleanup and
the Nix smoke minimum-version parameter correction. A later owner-run root
nix flake check passed with the final parameter correction and official Org
source switch included, covering the required builds as well as checks. Other
platforms and complete interactive configuration startup were not validated.
Stale dtd/ocaml-interface/tsx aliases were removed when native symbols changed,
and patch hunk length was corrected; the final reported pass came from the owner.
Treefmt/nixfmt also supplies a formatter and flake check.

No Nix build or Emacs runtime suite was executed during memory reconstruction.
Historical source probes and owner reports retain their narrower scopes.
README now describes the committed source-package entry, guarded
initializers, source-injected wrapper, six check families and explicit lint
exemptions. The owner explicitly requires README to remain stable project
documentation, not an execution/experiment log; validation runs and temporary
verification methods belong in current memory. The current step's validation
is agent-executed, separate from the owner's passing checks for step one.
The inverted ignore whitelist requires explicit inclusion of new tracked files,
and TODO.md / INBOX.md / AGENTS.md are Git-ignored, so edits to them are
worktree-only.
Nested Twist experiments, scratch/backup directories, runtime notes/databases
and private identifiers are not the tracked project architecture.
