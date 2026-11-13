{
  runCommand,
  lib,
  emacsPackage,
  configurationPackage,
}:
runCommand "emarccs-startup-order"
  {
    EMARCCS_PACKAGE_DIRECTORY = "${configurationPackage}/share/emacs/site-lisp";
    EMARCCS_SITE_START = "${emacsPackage.deps}/share/emacs/site-lisp/site-start.el";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ${lib.getExe' emacsPackage "emacs"} --batch -Q --load ${./lisp/startup-order.el} --funcall ert-run-tests-batch-and-exit
    touch "$out"
  ''
