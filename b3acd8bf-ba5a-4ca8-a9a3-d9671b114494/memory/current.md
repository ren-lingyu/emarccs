# Nix helper and grammar discovery

## Scope and foundation
This is the July Nix/grammar discovery line, reconstructed from complete source
horizons without asserting original commit provenance or rerunning tests.
Package-specific treesit-auto patching stays self-contained and consumes the
aggregate grammar library. Dynamic unique-anchor lookup avoids brittle fixed
line numbers but is not fuzzy application.

## Helper ownership
After repeated use, extract shared functions into lib and instantiate them
with pkgs. Prefer small curried functions; use an attrset for complex options.
concatMapEmacsTwists passes variant name and configuration rather than redundant
pkgs arguments captured in the helper closure.
Keep nixpkgs lib and project helpers conceptually distinct, avoiding accidental
recursive self-reference. Do not infer that underscore-prefixed lexical locals
need renaming merely because public APIs need namespacing.

Input metadata owns Elisp dependencies, recipe source and Org's recipe preBuild.
Scope derivation overrides own patches, native tools and phases. Org's preBuild
stays with recipe data because it is part of the upstream recipe contract.
Normalize selected package overrides through these boundaries rather than
rewriting all package-specific behavior as one generic builder.

## Next action
Exercise grammar load-name behavior with actual runtime checks. A TSX library
being found did not establish that the expected language symbol was available.
