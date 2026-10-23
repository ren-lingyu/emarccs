{
  runCommand,
  coreutils,
  lib,
  emacsPackage,
  configurationPackage,
}:
# Recompile sources independently of the package build without running config.
runCommand "emarccs-elisp-byte-compile"
  {
    nativeBuildInputs = [ coreutils ];
    EMARCCS_ELISP_SOURCE = configurationPackage.src;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    timeout --kill-after=3s 60s \
      ${lib.getExe' emacsPackage "emacs"} --batch -q \
        --load ${./lisp/elisp-byte-compile.el}
    touch "$out"
  ''
