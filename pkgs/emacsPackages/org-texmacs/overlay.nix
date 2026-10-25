{ }:
final_: prev_:
let
  pkgs = final_.callPackage ({ pkgs }: pkgs) { };
in
{
  org-texmacs = final_.callPackage ./package.nix { texmacs = pkgs.texmacs-fandol; };
}
