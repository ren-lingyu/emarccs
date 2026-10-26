{
  lib,
  llib,
  overlays,
}:
{
  overlays = llib.packages.mkOverlays {
    root = ./.;
    overlayFile = "overlay.nix";
    groups = rec {
      default = {
        overlays = with overlays; [
          emacsPackages.org-texmacs
          texmacs-with-gotor-support
        ];
      };

      legacy = {
        export = true;
        overlays = default.overlays;
      };
    };
  };
}
