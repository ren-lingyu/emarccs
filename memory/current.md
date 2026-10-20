# Current memory

The represented state extracts reusable Nix helpers, separates flake context
from helpers, normalizes package overrides and introduces managed grammars plus
nix-ts-mode. Dual-entry startup and the Org/publishing workflow remain as
described in `architecture.md`.

The helper source stage is integrated. Its design distinguishes recipe/Elisp
metadata from native build adjustments and favors package-local patching.
A selected grammar library can exist without the expected initialization symbol;
full runtime coverage has not yet been adopted at this main boundary.

Next recover actual-output grammar enumeration, availability and parser checks,
then later alias corrections and Org workflow ownership.
This is retrospective static reconstruction, not fresh build/runtime proof;
project parents do not infer original session commits. See `reconstruction.md`.
