{ extraArgs }: final_: prev_: {
  emarccs = final_.callPackage ./package.nix {
    melpaBuild = extraArgs.mkMelpaBuild prev_.melpaBuild;
  };
}
