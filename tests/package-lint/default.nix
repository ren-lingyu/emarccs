{
  runCommand,
  coreutils,
  lib,
  emacsPackages,
  emacsPackage,
  configurationPackage,
}:
let
  packageLint = emacsPackages.package-lint;
in
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
        -L ${packageLint}/share/emacs/site-lisp/elpa/package-lint-${packageLint.version} \
        --load ${./lisp/emarccs-package-lint.el}
    touch "$out"
  ''
