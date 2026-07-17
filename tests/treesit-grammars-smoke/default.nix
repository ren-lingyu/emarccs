{ pkgs, emacsPackage } : (

  pkgs.runCommand "emarccs-treesit-grammars-smoke" {
    nativeBuildInputs = [
      emacsPackage
    ];
  } (builtins.concatStringsSep "\n" [
    "${pkgs.lib.getExe' emacsPackage "emacs"} --batch --load ${./lisp/treesit-grammars-smoke.el}"
    "touch \"$out\""
  ])

)
