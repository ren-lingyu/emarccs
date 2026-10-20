# Emarccs architecture

## Purpose and initialization
Personal Emacs configuration targeting Emacs 31+. Only the Nix entry exists:
`flake.nix` builds a twist.nix wrapper. No elisp file lives at the repository
root, and the configuration is not loaded through Emacs' native `init.el` /
`early-init.el` filenames.

`lisp/` is a flat set of `emarccs-*.el` modules carrying one namespace. The
wrapper's generated `site-start.el` adds `lisp/` to load-path with
eval-and-compile, requires `emarccs-bootstrap`, and installs an advice on
`startup--load-user-init-file`. That advice, when init-file-user is non-nil,
loads `emarccs-early-init.el` in the early-init phase and requires
`emarccs-init` in the init phase before delegating to the original function, so
nil init-file-user (including --no-init-file) still skips the whole
configuration. `emarccs-init` is the single entry; it requires the modules in a
fixed order and loads optional custom.el last.

`emarccs-early-init` disables package.el startup. Persistent frame defaults are
separate from first-frame bootstrap colors; theme configuration owns lasting
colors. Graphical font sizing prefers a nominal 4 mm face parameter when
physical dimensions are valid, accepting list or dotted-pair mm-size data,
then falls back to the smaller pixel ratio against 1920x1080 at height 110.
These are font parameters, not measured glyph dimensions.

## Package ownership and startup adapter
Packages come solely from the twist.nix wrapper. The former `lisp/pure-emacs/`
straight bootstrap, the root `init.el`/`early-init.el`, and the
`pkgs/*/straight-register.el` recipe convention were removed; the pure entry is
gone rather than merely unmaintained. Module files use `emarccs-<name>.el` /
feature `emarccs-<name>`, while `emarccs--<name>.el` (currently
`emarccs--org-extension-block.el`) marks a private module. The double hyphen
inside symbols such as `emarccs--org-extension-block--source-namespace` denotes
a second, different privacy scope and is not planned for flattening.

`emarccs-bootstrap.el` exists solely because the advice defining a non-standard
early-init must be loaded at site-start time while the configuration itself must
run in the init phase; loading `emarccs-init` from site-start would run the whole
configuration before early-init. The flake renders these three forms through
nix-to-lisp. Emacs 31's native loader boundary preserves store early-init, real
user early-init, configuration and real user init ordering. Do not reset
user-emacs-directory to test this behavior. The advice parameter was renamed to
avoid shadowing Emacs' early-init-file.

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
Five project check families cover independent byte compilation, startup injection,
adapter phase ordering, library availability and produced-grammar loadability.
Compilation loads package autoloads, fakes local feature presence and uses disposable destinations;
it does not run the modules, and it no longer needs a fake straight bootstrap now
that no source file references straight.el. The byte-compile input is `lisp/` only.
Startup injection greps the wrapper's generated site-start.el for the load-path
setup, the bootstrap feature, the advice target and the early-init path, then runs
a batch smoke test asserting the bootstrap feature loaded and `emarccs-init` is
locatable; the two former load-path substring checks were dropped because the
flattened layout made them meaningless. Grammar checks enumerate actual output
libraries, test language availability and create parsers with diagnostic symbol
candidates.
The fifth family, startup-order, now uses `--batch -Q` with explicitly loaded
bootstrap source and ERT minimal payloads. It checks adapter ordering and
init-file-user=nil behavior without loading the full configuration; it does
not test the actual native startup sequence or wrapper wiring. The original
interactive version failed in an owner-run flake check; the replacement is
committed and its corrected GTK/PGTK checks passed in the owner-run x86_64-linux
flake validation. The agent did not run that validation.
Grammar checks do not prove real-source parsing, modes, font locking or indentation.
Stale dtd/ocaml-interface/tsx aliases were removed when native symbols changed,
and patch hunk length was corrected; the final reported pass came from the owner.
Treefmt/nixfmt also supplies a formatter and flake check.

No Nix build or Emacs runtime suite was executed during memory reconstruction.
Historical source probes and owner reports retain their narrower scopes.
README is reconciled and committed with the step-one refactor, including the
single-entry layout, helpers, package-directory assertions, the input and two
scope interfaces, current package adaptations, all five checks and treefmt.
It attributes the passing x86_64-linux flake validation to the owner and does
not claim complete interactive startup or coverage of omitted platforms.
The inverted ignore whitelist requires explicit inclusion of new tracked files,
and TODO.md / INBOX.md / AGENTS.md are Git-ignored, so edits to them are
worktree-only.
Nested Twist experiments, scratch/backup directories, runtime notes/databases
and private identifiers are not the tracked project architecture.
