# Emarccs architecture

## Represented baseline

This state is a mature single-entry Emacs configuration with an early startup
phase and a Home Manager deployment interface. Package acquisition is still
owned by interactive configuration; no separate package environment exists.

## Startup and package ownership

Root `init.el` adds `lisp/` relative to the user's Emacs directory and loads an
optional `custom.el` before configuration modules. The minimum is enforced at
Emacs 28.1, with a message below 30.1. `early-init.el` disables package.el startup,
sets straight defaults, suppresses asynchronous compiler warnings, and establishes
initial/default frame parameters before normal module loading.

`init-basic.el` owns straight.el bootstrap and use-package defaults as well as
general editor behavior. A missing bootstrap can initiate a synchronous
download. Package acquisition and interactive configuration are consequently
coupled. Use-package declarations throughout the modules describe dependencies
and configure their behavior; this is not an isolated prebuilt package set.
Backup and state locations depend on the user's Emacs directory.

## Capability boundaries

Modules cover editing and completion, help, theme, Org, TeX, snippets,
Org-roam, citation integration, LaTeX preview, publishing, the personal
integration layer and debugging. Entry-point require order supplies implicit
dependencies. Feed and AI modules are now enabled by the entry point. A file's presence
alone still does not establish that startup enables it.

The editor layer combines Consult, Vertico, Orderless, Marginalia and Embark
with general navigation, input and language conveniences. Theme and frame
preferences include daemon display guards and resolution-based proportional
font scaling. The selected display state precedes physical-dimension sizing;
resolution is a fallback heuristic rather than a physical glyph measurement.
Dirvish-based file management, structural highlights, large-file handling,
Tree-sitter language conveniences and expanded mathematical snippets have joined
the basic workflow.

Org is the central document and task substrate. It uses the tecosaur Org fork
and a recipe pre-build step to generate Org version metadata. Capture, agenda,
GTD, citation processors and export customization live alongside this package
setup. The Org directory is a runtime data root, not repository-owned content.

Org-roam adds a database, capture conventions, node navigation and organization.
The organization API here still uses older slash-style settings and directory
creation conventions. Bibliographic selection and citation-node integration
span separate citation and roam modules. Their loading order matters.

LaTeX editing, mathematical snippets and Org preview form a connected authoring
toolchain. External TeX tools and a local preview/export setup are environmental
requirements; configuration alone does not verify those tools are installed.

## Publishing and integration

The native Org publishing layer supplies HTML metadata, sitemap/index handling,
asset publication and site customization. A database-aware file-selection advice
can choose file-level Org-roam nodes by tags and path scope, while including
generated index/sitemap paths. An older preparatory file generator remains
defined; its existence does not make it the active project selection path.

The `init-orgraph.el` module is a personal integration aggregate. It connects
the Org-root-relative bibliography and export setup, LaTeX preview, package
loading, note timestamp hooks and automatic publication of selected saved notes.
This creates substantial cross-module ownership and load-order coupling.
Local content, tag identifiers and site details are intentionally not reproduced.

## Repository and operational boundaries

The repository is configuration source, not the Org database or note archive.
Its inverted ignore whitelist controls which files become visible to Git.
The Home Manager flake links early-init, init and the Lisp tree into a configurable
Emacs configuration directory. This deploys configuration files; it does not
provide or lock the Emacs package environment. Straight bootstrap remains the
package acquisition path. Declarative registries, startup smoke suites and
whole-set grammar runtime checks do not yet belong to this represented state.

Static inspection establishes these responsibilities and entry relationships.
It does not prove a fresh bootstrap, GUI startup, publishing, database mutation
or TeX execution succeeds. Before operating on live notes or the user's Emacs
state, recover current permissions and validate the relevant environment.
