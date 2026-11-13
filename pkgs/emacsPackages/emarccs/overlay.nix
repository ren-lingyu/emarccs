{ extraArgs }: final_: prev_: {
  emarccs = final_.callPackage ./package.nix {
    inherit (extraArgs) withProgress;
    melpaBuild = extraArgs.mkMelpaBuild prev_.melpaBuild;
  };
}
