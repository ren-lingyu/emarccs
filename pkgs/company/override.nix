{ pkgs, ... }: {
  scope = {
    overrideAttrs = { old, ... }: {
      src = pkgs.applyPatches {
        name = "company-patched-source";
        src = old.src;
        patches = [ ./texinfo.patch ];
      };
    };
  };
}
