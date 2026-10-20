{
  pkgs,
  lib,
  emacsPackage,
  elispSource,
}:
builtins.derivation {

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

  HOME = "/tmp/home/";

}
