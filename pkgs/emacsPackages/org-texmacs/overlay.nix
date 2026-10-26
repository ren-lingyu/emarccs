{ }:
final_: prev_:
let
  pkgs = final_.callPackage ({ pkgs }: pkgs) { };
in
{
  org-texmacs = prev_.org-texmacs.override { texmacs = pkgs.texmacs-fandol; };
}
