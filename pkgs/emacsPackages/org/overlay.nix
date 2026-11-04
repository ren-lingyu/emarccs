{ extraArgs }: final_: prev_: {
  org = final_.callPackage ./package.nix {
    src = extraArgs.sources.org;
    csl-locales = extraArgs.sources.csl-locales;
  };
}
