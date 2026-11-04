{ extraArgs }: final_: prev_: {
  org-include-inline = final_.callPackage ./package.nix {
    src = extraArgs.sources.org-include-inline;
    melpaBuild = extraArgs.mkMelpaBuild prev_.melpaBuild;
  };
}
