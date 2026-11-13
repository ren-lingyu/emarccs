{ extraArgs }: final_: prev_: {
  emarccs = final_.callPackage ./package.nix {
    inherit (extraArgs) mkChecks;
    emacs = final_.emacs;
  };
}
