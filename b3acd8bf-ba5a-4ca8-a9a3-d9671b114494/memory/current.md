# Nix helper and grammar discovery

## Source and retained design
This line spans the July 16-18 helper/grammar work and July 26-28 correction,
both starting in this project. Full horizons were surveyed for consequential
states. Exact original commit provenance is incomplete; source reports do not
constitute fresh checks now.

Shared helpers capture pkgs, offer curried small interfaces and attrsets for
complex operations. Input data owns Elisp dependencies and recipe hooks;
derivation overrides own native tools, patches and phases. Package-specific
patching remains self-contained with unique-anchor lookup.

## Full grammar policy
Use with-all-grammars and enumerate actual output shared objects. Check language
availability and parser creation, with symbol candidates in diagnostics.
The earlier shortlist missed languages; a whole-output test avoids maintaining
a stale parallel grammar list. Loadability is narrower than real parsing,
font locking or editor-mode correctness.

## Corrected failure diagnosis
Later outputs exported their own dtd, ocaml_interface and tsx initialization
names. Old aliases to xml, ocaml and typescript became wrong. The initial claim
that the test was too strict was corrected after inspecting actual files:
remove the three stale aliases.
Removing patch lines without adjusting its hunk length caused a separate
malformed-patch failure; the hunk length was corrected from eleven to eight.
The owner subsequently reported tests passing. The agent did not perform a
new complete check after that correction.

A lock update alone can expose this integration mismatch; pair the relevant
patch correction with it. This is not automatically a public breaking change.
An earlier org-roam-organize parse/EOF build failure is a separate event and
must not be conflated with the later native grammar failure.

## Completion
The source is ready for formal adoption at the helper, full-runtime and
later correction boundaries. Preserve the actual-output diagnosis and
owner-reported validation qualification when retaining this final state.
