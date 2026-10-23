{
  pkgs,
  packages,
  lib,
  llib,
  overlay,
}:
let
  args_ = {
    root = ./.;
    overlayFile = "test-overlay.nix";
    separator = "-";
  };
in
lib.concatMapAttrs (
  name_: value_:
  lib.mapAttrs'
    (checkName_: check_: {
      name = "${name_}${args_.separator}${checkName_}";
      value = check_;
    })
    (
      llib.tests.mkChecks {
        inherit (args_) root overlayFile separator;

        args = rec {
          inherit lib;
          inherit (pkgs)
            runCommand
            coreutils
            gnugrep
            ripgrep
            ;
          emacsPackagesPackageLint = pkgs.emacsPackages.package-lint;
          emacsPackage = value_;
          configurationPackage = emacsPackage.emacs.pkgs.emarccs;
          grammarPackage = emacsPackage.emacs.pkgs.treesit-grammars.with-all-grammars;
          overlayPackage =
            (import pkgs.path {
              inherit (pkgs) config;
              system = pkgs.stdenv.hostPlatform.system;
              overlays = [ overlay ];
            }).${name_};
        };
      }
    )
) packages
