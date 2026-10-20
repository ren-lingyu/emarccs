# Current memory

The represented project separates pure bootstrap from shared configuration and
centralizes straight recipes under package directories. Shared startup retains
module ordering and late customization; Home Manager still deploys source files.
Read `architecture.md` for the complete state.

Reconstruction has integrated the display/startup line and the relevant
dual-entry source stage. The retained packaging stage includes later experimental
startup findings; those explain the design but do not make the corresponding
Nix wrapper part of this earlier main tree.

Next recover the complete declarative Twist environment, variants, generated
startup adapters and checks. Preserve the distinction between main adoption,
nested experiments and the limits of fresh pure bootstrap.

Project parents identify trees inspected now. No original session execution
commit or fresh build/runtime validation is asserted. See `reconstruction.md`.
