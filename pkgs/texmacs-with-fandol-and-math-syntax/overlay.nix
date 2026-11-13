{ extraArgs }: final_: prev_: {
  texmacs-with-fandol-and-math-syntax = final_.callPackage ./package.nix {
    inherit (extraArgs) withProgress;
    fandol = final_.texlive.pkgs.fandol.tex;
    texmacs = final_.texmacs-with-gotor-support;
  };
}
