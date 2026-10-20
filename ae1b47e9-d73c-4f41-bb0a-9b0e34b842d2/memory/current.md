# Dual-entry packaging discovery

## Scope
Recovered from the long July 7-16 packaging session, surveyed across its full
substantive horizon. Work alternates between this project and a nested Twist
checkout. Experiments in that checkout explain decisions but are not proof
of main adoption. Later settings-only tail events add no project state.
Exact original project commit provenance is incomplete. Validation is historical.

## Package ownership decision
Support straight-based pure Emacs and a declarative Nix environment using the
same configuration. Do not add :ensure everywhere to shared declarations.
Reject alwaysEnsure: it unnecessarily fetches built-ins such as which-key.
Seed explicit extraPackages and allow dependency closure to follow package
metadata. Installing a package does not imply enabling all its configuration.

Use Twist's package locks, rather than one flake input per Elisp package.
initFiles may be empty: this controls parsing inputs, not execution of the
whole interactive configuration. Prefer makeEnv over the deprecated overlay
interface. Early experiments used Emacs 30.2; native startup integration later
motivates an Emacs 31 target.

The tecosaur Org fork needs generated org-version metadata from its recipe
pre-build. A Koishi recipe demonstrated explicit package injection. Compiler
or loaddefs warnings alone are not runtime failure evidence.

## Open work
Complete package adapters and test actual dependency behavior before claiming
the explicit environment covers the configuration. No fresh build is performed.
