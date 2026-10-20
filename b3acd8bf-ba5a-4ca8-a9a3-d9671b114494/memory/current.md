# Nix helper and grammar discovery

## Scope and helper contract
The July Nix/grammar source favors self-contained package overrides and shared
helpers after repeated use. Project helpers capture pkgs; simple interfaces
are curried, complex ones take attrsets. Recipe/dependency metadata and native
derivation adjustments remain distinct. No checks are run during reconstruction.

## Grammar acceptance boundary
A static language shortlist first missed jsdoc. Broader selection reached 126
languages with special load aliases, then with-all-grammars covered the actual
282-output environment and exposed more missing names. Test the complete
produced grammar directory, not a parallel hand-maintained whitelist.

Enumerate actual shared objects and check both treesit-language-available-p and
parser creation, reporting candidate initialization symbols on failure.
This validates discovery and loadability. It does not validate font locking,
major-mode activation, indentation or correctness on a real parse corpus.
TSX initially required a TypeScript initialization-name override; additional
special aliases matched the then-built native libraries.

## Open correction risk
Load aliases depend on the actual grammar outputs and can become stale after
lock updates. Inspect symbols and produced files before blaming a runtime test
for rejecting a newly built grammar.
