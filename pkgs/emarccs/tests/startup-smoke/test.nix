{
  runCommand,
  lib,
  emacsPackage,
  configurationPackage,
}:
runCommand "emarccs-startup-smoke"
  {
    MIN_EMACS_VERSION = "31.1";
    EMARCCS_SITE_START = "${emacsPackage.deps}/share/emacs/site-lisp/site-start.el";
    EMARCCS_PACKAGE_DIRECTORY = "${configurationPackage}/share/emacs/site-lisp";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ${lib.getExe' emacsPackage "emacs"} --batch -q --load ${./lisp/startup-smoke.el}
    touch "$out"
  ''
