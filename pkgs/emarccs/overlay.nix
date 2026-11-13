{ extraArgs }: final_: prev_: {
  emarccs = final_.callPackage ./package.nix {
    inherit (extraArgs) mkChecks withProgress;
    emacs = final_.emacs;
  };
}
