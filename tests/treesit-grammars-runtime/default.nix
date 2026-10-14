{
  pkgs,
  lib,
  emacsPackage,
}:
(

  pkgs.runCommand "emarccs-treesit-grammars-runtime" { nativeBuildInputs = [ emacsPackage ]; } (
    builtins.concatStringsSep "\n" [
      "${lib.getExe' emacsPackage "emacs"} --batch --load ${./lisp/treesit-grammars-runtime.el}"
      "touch \"$out\""
    ]
  )

)
