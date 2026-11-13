{
  pkgs,
  packages,
  lib,
  runCommand,
  overlay,
}:
let
  overlayPackages = import pkgs.path {
    inherit (pkgs) config;
    system = pkgs.stdenv.hostPlatform.system;
    overlays = [ overlay ];
  };

  assertions = lib.mapAttrsRecursiveCond (value_: !lib.isDerivation value_) (
    path_: value_:
    lib.assertMsg (
      (lib.getAttrFromPath path_ overlayPackages).drvPath == value_.drvPath
    ) "The default overlay does not produce the expected derivation at ${builtins.toJSON path_}."
  ) packages;
in
assert lib.all lib.id (lib.collect builtins.isBool assertions);
runCommand "overlay-equivalence" { } ''
  touch "$out"
''
