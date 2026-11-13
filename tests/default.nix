{
  pkgs,
  packages,
  lib,
  llib,
  overlay,
}:
llib.tests.mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  checks = lib.mapAttrsRecursiveCond (value_: !lib.isDerivation value_) (
    path_: value_: value_.tests or { }
  ) packages;

  args = {
    inherit
      pkgs
      packages
      lib
      overlay
      ;
    inherit (pkgs) runCommand writeText;
    inherit (llib.tests) withProgress;
  };
}
