{ extraArgs }: final_: prev_: {
  org-workbench = final_.callPackage ./package.nix {
    src = extraArgs.sources.org-workbench;
  };
}
