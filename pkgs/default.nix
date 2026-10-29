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
        overlays = builtins.concatLists [
          (with (overlays.emacsPackages); [
            org-texmacs
            org-roam-organize
            org-roam-include
            org-roam-blog
          ])
          (with overlays; [ texmacs-with-gotor-support ])
        ];
      };

      legacy = {
        export = true;
        overlays = default.overlays;
      };
    };
  };
}
