{ lib, llib }: rec {
  overlays = {
    default = lib.composeManyExtensions (
      builtins.attrValues (
        llib.packages.mkOverlays {
          root = ./.;
          overlayFile = "overlay.nix";
        }
      )
    );

    legacy = lib.composeManyExtensions [
      overlays.default
      (
        final_: prev_:
        assert lib.assertMsg (
          !(prev_ ? legacyPackages)
        ) "legacy overlay: `legacyPackages` already exists in the package set";
        {
          legacyPackages = llib.packages.mkLegacyPackages {
            root = ./.;
            overlayFile = "overlay.nix";
            pkgs = final_;
          };
        }
      )
    ];
  };
}
