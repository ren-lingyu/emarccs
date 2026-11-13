{
  lib,
  mkChecks,
  runCommand,
  emacsPackage,
  checks ? { },
}:
mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  inherit checks;

  args = {
    inherit lib runCommand emacsPackage;
    configurationPackage = emacsPackage.emacs.pkgs.emarccs;
  };
}
