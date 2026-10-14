{ pkgs, lib, emacsPackage, elispSource } : builtins.derivation {

  name = "emarccs-elisp-byte-compile";

  system = pkgs.stdenv.buildPlatform.system;

  builder = lib.getExe' pkgs.guile "guile";

  args = [
    "--no-auto-compile"
    "-s"
    ./lisp/builder.scm
  ];

  EMACS = lib.getExe' emacsPackage "emacs";

  EMARCCS_BYTE_COMPILE_SCRIPT = ./lisp/elisp-byte-compile.el;

  EMARCCS_ELISP_SOURCE = elispSource;

  EMARCCS_STRAIGHT_BASE_DIR = (pkgs.writeTextDir
    "straight/repos/straight.el/bootstrap.el"
    (builtins.concatStringsSep "\n" [
      '';;; -*- lexical-binding: t; -*-''
      ''(defun straight-use-package (&rest _args) t)''
      ''(defun straight-register-package (&rest _args) t)''
      ''(provide 'straight)''
    ])
  );

  HOME = "/tmp/home/";

}
