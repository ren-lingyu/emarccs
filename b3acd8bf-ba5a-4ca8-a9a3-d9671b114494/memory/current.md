# Nix helper and grammar discovery

## Scope
Recovered from the July 16-18 Nix/grammar session, surveyed through the helper
and full-grammar investigations. A later July 26-28 correction belongs to the
same source line. Exact original project provenance is incomplete; no fresh
Nix/Emacs checks are run here.

## Initial design
Keep package-specific behavior in package overrides, not scattered flake glue.
Register nix-ts-mode and integrate managed native Tree-sitter grammars.
Use the aggregate grammar store library instead of copying parsers individually.
The treesit-auto recipe patch should be self-contained and locate a unique
source anchor dynamically. A computed exact line is not fuzzy patch matching
or a promise to tolerate arbitrary upstream changes.

## Unresolved boundary
Finding a grammar library does not prove its initialization symbol matches the
requested language. Extract shared helpers only once repeated use justifies
a public interface; avoid declaring later full-set coverage at this stage.
