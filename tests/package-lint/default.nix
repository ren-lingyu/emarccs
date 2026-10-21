{
  pkgs,
  lib,
  emacsPackage,
  elispSource,
}:
let
  packageLint = pkgs.emacsPackages.package-lint;
in
pkgs.runCommand "emarccs-package-lint"
  {
    nativeBuildInputs = [ pkgs.coreutils ];
    EMARCCS_ELISP_SOURCE = elispSource;
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
