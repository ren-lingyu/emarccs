{ }: final_: prev_: {
  texmacs-fandol = final_.callPackage ./package.nix { fandol = final_.texlive.pkgs.fandol.tex; };
}
