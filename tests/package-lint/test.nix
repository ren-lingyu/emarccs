{
  runCommand,
  coreutils,
  lib,
  package-lint,
  emacsPackage,
  configurationPackage,
}:
runCommand "emarccs-package-lint"
  {
    nativeBuildInputs = [ coreutils ];
    EMARCCS_ELISP_SOURCE = configurationPackage.src;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    timeout --kill-after=3s 20s \
      ${lib.getExe' emacsPackage "emacs"} --batch -Q \
        -L ${package-lint}/share/emacs/site-lisp/elpa/package-lint-${package-lint.version} \
        --load ${./lisp/emarccs-package-lint.el}
    touch "$out"
  ''
