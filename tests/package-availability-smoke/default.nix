{
  pkgs,
  lib,
  emacsPackage,
  elispPackages,
}:
(

  pkgs.runCommand "emarccs-package-availability-smoke" { nativeBuildInputs = [ emacsPackage ]; } (
    builtins.concatStringsSep "\n" [
      "PACKAGE_NAMES=${lib.escapeShellArg (builtins.concatStringsSep " " elispPackages)} ${lib.getExe' emacsPackage "emacs"} --batch --load ${./lisp/package-availability-smoke.el}"
      "touch \"$out\""
    ]
  )

)
