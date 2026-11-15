# Emarccs architecture

## Current package ownership and sources
flake.nix is the boundary for external inputs; package files never access
flake inputs directly. Direct inputs are nixpkgs, personal-nixpkgs,
org-texmacs, org-roam-organize, org-roam-include and org-roam-blog (all
flakes), plus flake = false sources org, org-include-inline, org-workbench
and csl-locales. The root passes external overlays and sources explicitly to
pkgs/default.nix: overlays.emacsPackages carries the four package flakes'
Emacs overlays, overlays.texmacs-with-gotor-support carries org-texmacs's
TeXmacs overlay, and sources carries the four non-flake inputs.

Package definitions for org-texmacs, org-roam-organize, org-roam-include and
org-roam-blog belong to their upstream flake inputs; no local recipes remain
for the three Org-roam packages, and their configuration packageRequires are
retained. Emarccs keeps consumer-specific customization: a local org-texmacs
overlay leaf that only selects the TeXmacs program, local packages built from
flake sources (org, org-include-inline, org-workbench), local overrides
(consult, ripgrep, treesit-auto, haskell-ts-mode), the configuration package
and the three wrappers. It does not re-maintain recipes provided upstream.

The Org recipe bundles csl-locales: postPatch copies locales-*.xml into
etc/csl/ and appends a source/CC BY-SA 3.0 note to etc/csl/README; its files
selection includes etc/ so the locale data ships with the package, and
meta.license declares gpl3Plus plus cc-by-sa-30. org-include-inline and org-workbench apply
local byte-compile-warning patches and enable turnCompilationWarningToError.

lib/mkMelpaBuild.nix wraps Nixpkgs melpaBuild to derive package metadata from
the main Elisp file headers: version prefers Package-Version over Version
(case-insensitive header match), melpaVersion defaults to version with "-pre"
rewritten to "pre", homepage comes from the URL header. Caller-provided
version/melpaVersion/meta.homepage win. The library file is <ename>.el at the
source root, then lisp/<ename>.el, or an explicit libraryFile; a missing
version header with no override throws. This is a local recipe helper, not a
shared personal-nixpkgs interface or a MELPA dependency solver.

## TeXmacs resource package and math syntax
pkgs/texmacs-with-fandol-and-math-syntax replaces the former
pkgs/texmacs-fandol symlinkJoin/makeWrapper font-prefix package
(ef09c70, BREAKING-CHANGE). It applies overrideAttrs to the upstream
texmacs-with-gotor-support from org-texmacs's TeXmacs overlay, preserving the
GoToR fix. postPatch installs the complete Fandol OTF set from
texlive.pkgs.fandol.tex into TeXmacs/fonts/truetype/fandol/ and the generated
style into TeXmacs/packages/emarccs/emarccs-math.ts. There is no standalone
font wrapper, no global replacement of pkgs.texmacs, and no modification of
TeXmacs built-in styles.

math/registry.nix holds native delimiter codes; math/default.nix generates the
style string in pure Nix; writeText turns it into a build input exposed as
passthru.mathStyle (independently buildable). No external generator or IFD.
Codes are l<count><kind>/r<count><kind> with aliases for single-layer forms,
plus n as the invisible delimiter: 47 codes in total. All 2208 ordered pairs
except nn are generated; each pair yields one unary macro and one concat-
prefixed variadic macro (4416 delimiter macros), plus an application macro.
Exact names and the registry stay authoritative in source and README.

passthru.tests provides resources and math-syntax. resources byte-compares the
installed style with the generated file, checks the 4417 assign lines and
representative definitions, rejects any nn macro, and byte-compares installed
Fandol fonts against their source. math-syntax renders a native document using
the custom macros and an equivalent reference document with explicit around*
markup in headless TeXmacs (offscreen Qt, isolated HOME/TEXMACS_HOME_PATH),
then compares extracted PDF text and single-page raster output. It keeps the
180s render timeout with a 5s kill grace, does not depend on Emacs or
Org-TeXmacs, and does not validate every delimiter glyph.

The local org-texmacs overlay selects this package as the default program via
prev_.org-texmacs.override { texmacs = ...; }; callers can still override the
program. Responsibility split: Emarccs defines personal math notation and
packages the style, Org-TeXmacs converts documents, TeXmacs renders math.
Font resources, document language, math syntax and export conversion are
distinct responsibilities.

## Current shared flake foundation
The root uses personal-nixpkgs.lib.mkFlake inputs.nixpkgs with an argument
function supplying inputs/moduleLocation/llib/lpkgs and the project module.
llib merges the shared library's tests and packages with the local ./lib
extension through mergeAttrsRecursive { allowOverrides = false; }; local
lib/default.nix contributes mkMelpaBuild and tests.withProgress. The helper
injects the selected Nixpkgs lib, imports shared package/tool/treefmt
infrastructure and exposes perSystem nixpkgs.overlays; Emarccs sets that to
its legacy group rather than constructing _module.args.pkgs manually.
The explicit personal-nixpkgs/local-nixpkgs Git URL override is removed;
lock nodes use dependency-relative path locators. All four package flakes and
personal-nixpkgs declare inputs.nixpkgs.follows = "nixpkgs" at the root (the
lock resolves personal-nixpkgs's nixpkgs through org-roam-blog's nixpkgs
node). The lock still contains multiple transitive personal-nixpkgs
instances (one per consumer flake); they have not been flattened or assumed
to share one library revision.

The shared treefmt module handles Nix and Elisp formatting (among others),
uses elisp-autofmt for .el files, disables default exclusions and fails on
unmatched files. Emarccs enables flakeCheck and excludes only *.patch,
LICENSE and flake.lock; *.el, README.org and .gitignore are formatted. The
intermediate commit that excluded *.el (6ea3416) was superseded by the
restored formatting check (40e0945); no successful full check for the final
revision was supplied or executed by the agent.

README documents the shared interfaces Emarccs consumes (the mkFlake entry,
package and overlay discovery helpers, test aggregation helpers, and the
local llib merge with its collision policy) rather than the internal
dependency arrangement of the providing repository; the sentence describing
several personal-nixpkgs dependencies as following Emarccs root inputs was
removed. The project flake and lock were unchanged by that cleanup.

## Current package groups and exports
pkgs/default.nix uses llib.packages.mkOverlays with default and legacy groups.
Both groups apply the four external Emacs overlays (org-texmacs,
org-roam-organize, org-roam-include, org-roam-blog) and the external TeXmacs
overlay before local ones; legacy reuses default's list and adds export = true.
extraArgs injects lib, sources, mkMelpaBuild, mkChecks and withProgress.
flake.nix exposes flake.overlays.default = lpkgs.overlays.default, applies
lpkgs.overlays.legacy per system, exports pkgs.legacyPackages directly and
picks the three wrappers from pkgs. The migrated Org-roam packages have no
local overlay leaf, so individual legacyPackages.emacsPackages.org-roam-*
paths are not promised; local leaves (org, org-include-inline, org-workbench,
org-texmacs, treesit-auto, consult, ripgrep, haskell-ts-mode, emarccs and the
wrappers, texmacs-with-fandol-and-math-syntax) are discoverable for export.
Actual exports have not been re-evaluated after the shared-library updates;
confirm against the current selector before promising specific paths.

## Overlay constructor protocol
The shared-library loader requires source overlays and test overlays to be
constructors: { }: final: prev: ... even when no construction parameters are
needed. The loader instantiates the outer function before applying the
resulting ordinary overlay; extraArgs carries shared helpers.

## Package-owned tests and flake aggregation
Tests are owned by the object under test; the top-level flake aggregates a
finite package tree and checks its own contracts. pkgs/emacsPackages/emarccs/
package.nix builds the configuration package via melpaBuild, whose normal
install/compile flow is the compile check (no separate elisp-byte-compile
test exists). doCheck runs three independent batch Emacs processes in
checkPhase, each reported by withProgress: initialization (four ERT cases
against package sources), snippets (seven behavior ERT cases with real
package activation) and package-lint (all 18 source libraries, main file
emarccs.el). package-lint arrives via checkInputs, not runtime
packageRequires; test files live outside src and are not part of the MELPA
source archive. Existing explicit, narrow lint exemptions remain; compile
warnings are still not failures (turnCompilationWarningToError = false).

pkgs/emarccs/tests/ holds startup-smoke, startup-order and
package-availability-smoke. Tests use the final wrapper or its generated
startup form together with the matching configuration package. The three
wrapper variants share one definition and instantiate it per variant through
override. startup-smoke verifies batch startup leaves configuration
untouched, the installed configuration package resolves from the supplied
directory, requiring emarccs stays lazy, and a real package-activation run
with substituted initializers. startup-order runs three ERT cases against the
actual generated site-start form: phase order, hook uniqueness and disabled
user init. package-availability-smoke locates every declared packageRequires
library (auctex mapped to tex-site); it does not verify frontend autoloads or
full runtime behavior. Real package activation, substituted initializers and
complete interactive startup remain distinct scenarios.

treesit-auto owns its grammar runtime test (passthru.tests.grammars-runtime),
run in a minimal wrapper containing only treesit-auto and its propagated
dependencies. It enumerates the supplied libtree-sitter-*.so libraries and
checks library discovery plus parser creation, without adding directories to
the lookup path; it does not claim real source parsing, font-lock, indentation
or major-mode correctness.

The TeXmacs package owns resources and math-syntax as described above.
Top-level tests/default.nix invokes llib.tests.mkChecks once, aggregating the
recursive passthru.tests tree from the exported legacyPackages plus its own
test-overlay registrations (overlay-equivalence, with-progress), flattening
paths with "-". overlay-equivalence imports pkgs.path with only the exported
default overlay and recursively compares drvPaths during evaluation, then
produces an empty result. treefmt is the flake formatter check. No traversal
of the whole of Nixpkgs occurs.

## withProgress contract
lib/withProgress.nix, exposed as llib.tests.withProgress, is a local Bash
code-generation helper. It takes a nonempty name, a positive interval
(default 10) and text as either a Bash source string or a path read and
embedded at evaluation time. It requires Bash >= 5.3. It reports start,
periodic heartbeat and final passed/failed with elapsed time, reporting both
EPOCHREALTIME-derived signed realtime and BASH_MONOSECONDS monotonic elapsed
values, and preserves the wrapped code's exit status. The original code
inherits stdout/stderr, shell state and cwd; reporter output goes to stderr;
no output proxying or caching. Two subshells isolate reporter state from the
original code; a coproc with read -t provides the heartbeat and the EXIT trap
reclaims the reporter without waiting for a full next interval. The helper
creates no derivation, performs no test discovery or aggregation, imposes no
timeout and does not manage the task process tree. A heartbeat does not prove
progress and can affect Nix max-silent-time. The TeXmacs render timeout is
part of that test itself, not a withProgress feature.

## Org workflows and backend boundaries
The final Org-roam root is org-directory/roam/, with the database under that
root and dailies in journal/. All org-roam-organize registry records use
:directory ".", so node types are expressed through registry entries, tags,
templates and MOCs rather than physical subdirectories. The navigation MOC
uses a fixed ID and the unified inbox name is "Not be Classified". Capture
date templates use one shared format. Automatic DATE updates and their
before-save hooks were removed; org-roam-timestamps remains enabled with
timestamp-parent-file and remember-timestamps, a different mechanism.
Flattening the node-type directories and restoring the independent roam/ root
are complementary decisions. No claim is made that personal notes have been
migrated, and real note libraries are not inspected or modified by memory
work.

org-agenda-files contains org-directory and the explicit gtd/ directory. The
emarccs--org-agenda-files-advice constructor takes excluded-patterns and
returns a lexical-closure advice with a stable name. It delegates native
Org handling for restriction, archives, list-file entries and unavailable
files; for directory sources it recursively expands to directory lists
(excluding hidden directories and not descending into symlinked directories),
binds org-agenda-files dynamically and calls the native function. Exclusion
globs expand relative to org-directory and only filter recursively discovered
directories; explicit entries are never excluded. The current exclusions are
("cache"); the explicit gtd/ entry is kept for clients that read the variable
directly, even though it lies under the recursive root.

LaTeX output filters are registered only for backends derived from latex via
org-export-derived-backend-p inside org-export-filter-options-functions:
TOC placement after abstract/title and date angle-bracket cleanup. They do
not apply to TeXmacs or HTML exports. Backend-specific output transformation
is kept separate from generic Org preparation; personal LaTeX macro-package
evolution is not part of this repository's architecture record.

The Org-TeXmacs block in emarccs-org.el records consumer choices: export menu
keys, worker start/request timeouts (60/10), native citation processor with
plain bibliography style, typed references, document styles
generic/smart-ref/emarccs-math, A4 with 12.7mm margins, relative PDF links and
org-file-to-PDF linking, scheme-mode edit mode and fragment tags including
reference and rcl-table. These are personal configuration, not upstream
defaults or protocol. The emarccs--org-extension-block layer still exists;
the new canonical statement TYPE snippets do not extend the old ext namespace,
which neither removes the layer nor migrates old documents. Fragment
recognition and independent editing are outside the snippet reorganization.

## Snippet architecture
Completion and snippet expansion are separate responsibilities: Company
configuration lives in emarccs-basic (candidate-driven completion), while
emarccs-snippet (renamed from emarccs-complete, no compatibility alias)
manages AAS, LAAS and YASnippet. The snippet module enables yas-minor-mode
and AAS in LaTeX and Org buffers, and LAAS with its upstream default
basic/subscript/fraction/accent snippets explicitly disabled (set to nil,
not merely cleared) plus local laas-mode snippets.

AAS native yas expansions are used: a generic Org block constructor defined
in aas :config returns (list 'yas (format "#+begin_${1:%s}%s\n$0\n#+end_$1\n"
name parameters)), where the opening block name is an editable field, the
closing name mirrors it, $0 is the body position and parameters sit outside
the mirrored field. Starred variants come from editing the name field, not
separate triggers. The constructor supports 10 general/math/floating block
triggers and 16 formal statement triggers; statements use the Org-TeXmacs
canonical #+begin_statement TYPE form without extending the ext namespace.
AAS registration needs no YASnippet load order, and no constructor closure or
declare-function for expansion exists; LAAS's package dependency on AAS is
separate from AAS's optional use of YASnippet expansion.

Org blocks use the ;; prefix; ; remains for LaTeX structures and plain text.
;abst/;comm became ;;abst/;;comm, ;eq remains LaTeX inline math while ;;eq is
the Org equation block; their suffix overlap is covered by input tests.
Existing LaTeX fragment/environment commands (insert-based, unchanged),
parameterized math structures, delimiters, Physics2 macros and the long-vowel
text snippets are retained. Custom Greek/Hebrew letters and the eight
single-symbol math snippets (;uniti ;hom ;end ;id ;ker ;im ;tr ;times) are
removed. No tag-specific STM snippets were added: STM has a uniform
S-expression structure and its macro semantics belong to the TeXmacs style,
not the snippet layer; only Org ;par -> (|) exists for explicit
S-expressions. Scheme and Scheme Tree-sitter modes deliberately do not enable
AAS/LAAS/YASnippet; parentheses and structure editing rely on ordinary
Scheme/Lisp editing facilities, and no electric-pair configuration was added.

Seven behavior ERT cases in the package's snippets check drive real mode
hooks and key input through AAS, LAAS, YASnippet and execute-kbd-macro:
org-blocks (all 26 block triggers with wrapper, field jump and body),
block-name-mirror (equation*, figure*, table* and a custom name),
parentheses, scheme-isolation (scheme-mode only; the Tree-sitter variant is
not separately exercised), retained-latex (a subset of LaTeX behaviors),
removed-symbols (disabled defaults plus removed triggers stay literal) and
retained-text. Coverage follows the actual tests, not a per-trigger matrix.

## Historical Scheme isolation failure and potential AAS defect
An intermediate implementation enabled AAS/YASnippet in Scheme buffers to
reuse ;par. A new seven-case ERT had six passes; scheme-isolation failed:
with LAAS disabled in Scheme, typing ;;eq still expanded to an Org equation
block. Source analysis of upstream AAS found aas--current-prefix-maps
declared with defvar-local and a (list nil) default, while matching mutates
the list in place (nconc/setcar/setcdr); defvar-local does not guarantee each
buffer a fresh mutable list on first read, so mutation of the shared default
can leak into later buffers, and the post-expansion reassignment does not
restore an already-mutated default object. Running several ERT cases in one
Emacs process makes this visible, but that is not a test defect: interactive
Emacs also shares one process across buffers. The proposed fixes (setq-local
in an aas-mode hook, or nil default with lazy per-buffer initialization
upstream) were not adopted; no AAS patch or upstream PR exists.
The final decision removed AAS from Scheme entirely; two later test failures
were stale expectations and were corrected. Owner-reported final tests and
builds passed for the committed configuration. Distinguish the observed
anomaly, the strong static hypothesis about shared mutable defaults, the
absence of an independent minimal AAS-only reproduction, the unverified
upstream fix, and the fact that the final ERT validates Emarccs configuration
only. A future investigation should first build an AAS-only two-buffer
reproduction before considering an upstream patch.

## Earlier wrapper/activation baseline
Emarccs wrapper construction and site-start injection live in
pkgs/emarccs/package.nix: emacsPackagesFor/withPackages with emarccs and
coreutils, then overrideAttrs replacing the site-start insertion marker with
the guarded startup form (package-activate-all, require emarccs,
emarccs-initialize-early, before-init-hook registration) plus the two
declare-function forms. Root overlays define emarccs and derive GTK/PGTK
variants through override with the matching final Emacs. flake.nix exports
lpkgs.overlays.default directly; the former easyOverlay strategy, whose forced
external prev omitted local package definitions, is removed. Overlay
equivalence checks and wrapper/smoke realizations under the independent
overlay import were validated on x86_64-linux at the committed revision with
cached outputs; the owner committed the fix.

The preceding custom-package migration used melpaBuild for all seven former
trivialBuild derivations, generating ELPA metadata/autoloads; subsequently
the org-texmacs and three Org-roam source recipes moved to upstream inputs,
leaving historical builder context. Explicit files recipes use MELPA
defaults; org-texmacs also packages its Scheme worker upstream. The original
trivialBuild gap and later narrowed-glob omission explain earlier missing
interactive frontend commands; see current.md for evidence and limits.

## Purpose and initialization
Personal configuration targeting Emacs 31.1+, organized as an Elisp source
package under pkgs/emacsPackages/emarccs/lisp/ (18 libraries). emarccs.el
only requires the early-init and init interfaces; the wrapper owns startup
scheduling and requiring the entry never initializes configuration.
emarccs-initialize-early applies settings once and preserves later
overrides; emarccs-initialize requires use-package with always-ensure nil,
loads functional modules in fixed order (basic, help, theme, org, tex,
snippet, lisp, org-roam, org-roam-organize, org-latex-preview, feed,
org-roam-blog, debug), loads optional custom.el last, guards recursion and
repeat calls and marks completion only after success. Changing the module
order can change initialization semantics.

Early initialization owns two independent frame parameter lists:
default-frame-alist carries persistent frame defaults (maximized fullscreen,
disabled scroll/menu/tool bars) and initial-frame-alist carries first-frame
bootstrap appearance (gray10/gray90 colors plus the same chrome settings).
Theme configuration owns lasting colors. The lists have distinct
responsibilities and must not be replaced with one another merely to update
geometry.

The regular graphical configuration computes monitor-dependent width and
height and applies them to both lists independently through
emarccs-basic--frame-alist-with-geometry. The helper copies the input list
structure, removes existing entries keyed by the symbols width and height,
and prepends the new text-pixel dimensions; it does not modify the original
list structure and is not a deep copy of nested objects. The earlier
implementation used the computed numeric dimensions as assq-delete-all keys
(which never match the symbol keys), dynamically bound default-frame-alist
inside let*, and assigned initial-frame-alist from that temporary default
list; the new implementation drops those operations and updates both
variables from their own previous values, preserving unrelated entries such
as fullscreen and bootstrap appearance parameters.

The retained display strategy keeps the display-graphic-p guard, the
physical-dimension-based font sizing with its resolution-based fallback, the
font family and face settings, and the early maximization settings. The
dimension validity condition is factored into valid-geometry-p and reused
for both resolution-based font scaling and frame geometry updates; width and
height come directly from monitor-width and monitor-height, and invalid
dimensions do not trigger frame geometry replacement. These are committed
parameter assignments, not realized window sizes or compositor behavior.

Graphical font sizing prefers a nominal 4 mm face parameter when physical
dimensions are valid, accepting list or dotted-pair mm-size data, then falls
back to the smaller pixel ratio against 1920x1080 at height 110. These are
font parameters, not measured glyph dimensions.

## Naming and ownership conventions
Files/features use emarccs-<name>, with emarccs.el providing the main
library. The double hyphen in the private extension module and inside symbols
such as emarccs--org-extension-block--source-namespace marks distinct privacy
scopes; emarccs--org-roam-blog-* is deliberately preserved for the same
reason and is not a flattening defect. Public/private helper ownership
follows provided features and domain, using one/two hyphens respectively;
underscore lexical locals are a separate convention.

Nixpkgs helpers are lib; project helpers are lllib, instantiated through
mergeAttrsRecursive as described above. Local extension helpers
(mkMelpaBuild, withProgress) are not shared-library interfaces.

## Basic configuration conventions
use-package :hook declarations omit the conventional -hook suffix
(highlight-parentheses now uses :hook (minibuffer-setup .
highlight-parentheses-minibuffer-setup)); direct add-hook calls use actual
hook variable names. This is notation normalization, not a correction of a
demonstrated hook registration failure.

The compilation buffer display rule now matches the standard buffer name
exactly with (rx string-start "*compilation*" string-end), with rx required
within eval-when-compile. The display action (display-buffer-in-direction),
direction (below), requested height (window-height 6) and
compilation-scroll-output are unchanged. display-buffer-alist is still set
as a whole; the rule does not claim to cover every compilation-mode buffer
or to fix the window height permanently.

The embark-consult declaration dropped its :config form that explicitly
required embark-consult itself, retaining its :after and :hook settings;
this is removal of a redundant self-require in the configuration.

The removed emarccs-basic--spell-check-support-enabled-p constant is
historical: its tracked definition survived the namespace and layout
migrations (originally *spell-check-support-enabled* at d09aac5, renamed in
a0e3c90 and 672b9c0, relocated in a80a89a) with no tracked consumer anywhere
in project history, and was removed as unused configuration. No
compatibility alias or spelling-check implementation task exists.

## Shared behavior and workflow boundaries
Completion/navigation combines Consult, Vertico, Orderless, Marginalia and
Embark. Dirvish, structural highlighting, large-file support, whitespace
cleanup and margin diff-hl serve editing. Koishi setup and Doom modeline
replace the former multi-theme switcher. Common Lisp uses SLY/SBCL; Haskell
Tree-sitter mode uses Eglot. PDF files use pdf-view-mode and themed
rendering. Package availability does not prove a language server, external
executable or live workflow is configured.

Org owns capture, agenda/GTD, export and date helpers, with BibLaTeX for
LaTeX citations and a corrected bookmark-default-file. GTD uses its command
center and a complete done-state mapping instead of the earlier custom ID
advice. Org-roam owns database/autosync, capture, timestamps, post queries
and native forward-link navigation; consult-org-roam was removed.
Organization registries and org-roam-include replace legacy flat
organization settings. The organization module owns Citar/Citar-Embark and
declarative Citar literature backend fields with bibliography support. The
handwritten provider is gone; Citar-Org-Roam remains declared but disabled.
Citar waits for Org and Org-roam to avoid the earlier unbound-directory
failure.

Publishing orchestration belongs to external org-roam-blog. Emarccs
configures the site, org-roam-organize manages nodes/literature, and the
publishing package orchestrates output. The Org-roam DB remains the sole
source of publishable level-0 nodes without a directory-scan fallback;
handwritten index and about pages are legitimate nodes. Canonical output
should preserve source-relative structure for existing links; generated
public entries/redirects need not determine canonical content paths. Node
metadata comes from the DB, while position-sensitive #+INDEX annotations
belong to the export parse tree. Publishing should leave no permanent global
project-list changes, advice, export filters or save hooks, while still
running normal Org export hooks/filters including citation preprocessing.
These are recovered design requirements, not claims about external-package
verification. The former orgraph aggregate is gone: TeX owns export tools,
preview owns preview, and Org-roam owns date/post-query behavior. The former
AI module and unused package definitions are removed.

The custom eq: Org link type and its jump/export/display logic were removed
(26b05eb, BREAKING-CHANGE); documents using it must migrate to native Org
references or other supported mechanisms.

## Extension-block semantics
The project-local layer accepts #+begin_ext KIND :KEY VALUE. Recovered user
decisions chose one namespace to avoid native block-name collisions such as
example while keeping Org documents canonical and leaving the native parser
unchanged. Native special-block types and raw type/parameters are preserved;
normalization adds :extension-kind and validated :extension-parameters.
Registry spelling is canonical with case-insensitive lookup; unknown,
duplicate or valueless parameters are errors. Values remain source-form Org
secondary strings until backend export. HTML/LaTeX can lower to KIND or
preserve the distinct org-extension-block export namespace; local
configuration preserves it. The stable writing syntax is deliberately
independent of a backend's representation name. preserve-namespace changes
export lowering only, not canonical source or normalized AST semantics.
HTML lowers a copied node; LaTeX parameter export performs math wrapping and
rejects conflicting ATTR_LATEX options. Advice supports delayed exporter
activation and feature unload cleanup. Kinds include reply, mathematical
statements, exercise/exercise*, proof and solution. This is not a new native
Org AST element type. New statement snippets emit Org-TeXmacs canonical
statement blocks instead of extending this namespace.

Recovered user reports describe ordinary inline markup and links working in
HTML/LaTeX secondary-string export; this is limited historical evidence, not
acceptance of every secondary syntax. Reference material reports that
citations inside parameters can miss document-wide citation preprocessing
because synthetic secondary AST is parsed during block transcoding. No
corresponding fix is established by this reconstruction; do not claim
complete parameter citation support. Reassess the export pipeline before
changing it.

## TeXmacs historical validation boundaries
All font/cache/language probes described in current.md targeted the former
texmacs-fandol symlinkJoin wrapper (TEXMACS_FONT_PATH prefixing), the
then-current org-texmacs source 2c1c7d58 and TeXmacs 2.1.5, not the new
texmacs-with-fandol-and-math-syntax resource package. In particular:

- Fresh-profile Fandol PDF positives used the plain-base wrapper.
- The existing-profile <#...> reproduction and its font-database-extend-local
  repair, incremental registration results, --delete-font-cache behavior and
  the recommendation for documented manual cache clearing all apply to that
  old wrapper and its TEXMACS_FONT_PATH approach.
- The long-Chinese line-breaking matrix shows document language (initial
  language=chinese) fixes clipping while FandolSong font selection alone does
  not, and that the tested org-texmacs source rejects #+LANGUAGE: zh-CN. It
  did not test the new resource package.

None of these probes proves the new resource layout has the same
existing-profile behavior, nor that it is fixed. Do not adopt cache migration
helpers, global Chinese language defaults, Source Han font plans or any
historical recommendation without owner confirmation.

## Nixpkgs migration and earlier history
The committed 2026-10-22 migration superseded the Twist architecture:
Nixpkgs emacsPackagesFor/withPackages consumes the local emarccs package with
local dependency overlays; the wrapper's injected site-start owns early
initialization and before-init-hook registration; emarccs.el only requires
interface definitions. Old bootstrap/advice scheduling, root lisp/, Twist
runtime integration and lock/update apps are removed, and obsolete
Twist/registry inputs were removed in follow-ups. lib/packages.nix was
extracted to the personal-nixpkgs input; the local library extension and the
external merge combine as described above. Overlay discovery selects using
overlay files and package-set derivation attributes, not package.nix
presence; pure overrides may be inlined into their overlay without losing
legacy export eligibility. Consult propagates GNU grep and ripgrep; the
ripgrep Elisp override propagates system ripgrep from outer pkgs; Dired's
coreutils join the wrapper via withPackages. Earlier Twist-era detail
(registries, recipe conventions, per-variant locks, config.context) is
preserved in first-parent history and is not current design.

## Validation and repository boundaries
Static source verification for the current consolidation inspected the
37-commit range 534188d..8abd482 (diffs of the architectural anchors and the
final trees of flake.nix, pkgs/default.nix, lib/, the TeXmacs package, the
emarccs package and tests, treesit-auto, Org workflow and snippet sources,
README and .gitignore) with diff --check. No Nix evaluation, build, test,
formatter run or network access was performed by the agent for this state.
Owner-reported validation covers the final snippet implementation (tests and
builds all passed); it is owner-reported, was not repeated by the agent and
does not extend to other platforms or complete interactive environments.
No runtime result is recorded for the TeXmacs resource package or its tests.

The inverted .gitignore whitelist requires explicit inclusion of new tracked
files; *.scm is allowed under pkgs/ and *.sh under tests/ (moved from pkgs/).
README.org describes the committed architecture (ownership, outputs,
TeXmacs package, math syntax, package-owned tests, withProgress, snippets)
without experiment logs. The no-warning claim is not made anywhere: byte
compilation succeeds with warnings and package-lint retains its explicit
exemptions. Historical probes and owner reports retain their narrower scopes.
