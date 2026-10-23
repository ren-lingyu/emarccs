{
  runCommand,
  coreutils,
  gnugrep,
  ripgrep,
  lib,
  emacsPackage,
  configurationPackage,
}:
runCommand "emarccs-startup-smoke"
  {
    nativeBuildInputs = [ coreutils ];
    MIN_EMACS_VERSION = "31.1";
    EMARCCS_SITE_START = "${emacsPackage.deps}/share/emacs/site-lisp/site-start.el";
    EMARCCS_GREP = lib.getExe gnugrep;
    EMARCCS_RG = lib.getExe ripgrep;
    EMARCCS_LS = lib.getExe' coreutils "ls";
    EMARCCS_PACKAGE_DIRECTORY = "${configurationPackage}/share/emacs/site-lisp";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    PATH=/nonexistent ${coreutils}/bin/timeout --kill-after=3s 20s \
      ${lib.getExe' emacsPackage "emacs"} --batch -q \
        --load ${./lisp/startup-smoke.el}
    touch "$out"
  ''
