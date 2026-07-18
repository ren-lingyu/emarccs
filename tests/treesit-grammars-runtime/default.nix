{ pkgs, emacsPackage } : (

  pkgs.runCommand "emarccs-treesit-grammars-runtime" {
    nativeBuildInputs = [
      emacsPackage
    ];
  } (builtins.concatStringsSep "\n" [
    "${pkgs.lib.getExe' emacsPackage "emacs"} --batch --load ${./lisp/treesit-grammars-runtime.el}"
    "touch \"$out\""
  ])

)
