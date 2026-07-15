{ pkgs, emacsPackage, elispPackages } : (

  pkgs.runCommand "emarccs-package-availability-smoke" {
    nativeBuildInputs = [
      emacsPackage
    ];
  } (builtins.concatStringsSep "\n" [
    "PACKAGE_NAMES=${pkgs.lib.escapeShellArg (builtins.concatStringsSep " " elispPackages)} ${pkgs.lib.getExe' emacsPackage "emacs"} --batch --load ${./lisp/package-availability-smoke.el}"
    "touch \"$out\""
  ])

)
