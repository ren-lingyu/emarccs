{
  lib,
  mkChecks,
  withProgress,
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
    inherit
      lib
      runCommand
      emacsPackage
      withProgress
      ;
    configurationPackage = emacsPackage.emacs.pkgs.emarccs;
  };
}
