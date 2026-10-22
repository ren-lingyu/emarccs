final_: prev_:
let
  # Resolve system programs outside the Emacs package scope.
  pkgs = final_.callPackage ({ pkgs }: pkgs) { };
in
{
  consult = final_.callPackage ./package.nix {
    consult = prev_.consult;
    rg = pkgs.ripgrep;
  };
}
