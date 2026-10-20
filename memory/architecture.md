# Emarccs architecture

## Represented baseline

This state is a personal Emacs configuration organized around one interactive
startup and a shared Org-based knowledge workflow. It predates a separate
package environment or a pure/shared directory split.

## Startup and package ownership

Root `init.el` adds its `lisp/` directory to the load path and loads
`custom.el` before the configuration modules. The minimum version is enforced
at Emacs 28.1, with a message below 30.1. There is no separate early-init entry.

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
dependencies. An AI file exists but is not required by this entry; a project
module's presence likewise does not establish that startup enables it.

The editor layer combines Consult, Vertico, Orderless, Marginalia and Embark
with general navigation, input and language conveniences. Theme and frame
preferences are configuration responsibilities rather than a portable GUI
measurement contract.

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
The empty README at this baseline supplies no independent operational guide.
A flake, declarative package registry, startup smoke suite and grammar runtime
checks do not yet belong to this represented state.

Static inspection establishes these responsibilities and entry relationships.
It does not prove a fresh bootstrap, GUI startup, publishing, database mutation
or TeX execution succeeds. Before operating on live notes or the user's Emacs
state, recover current permissions and validate the relevant environment.
