{
  pkgs,
  lib,
  emacsPackage,
}:
pkgs.runCommand "emarccs-startup-order"
  {
    nativeBuildInputs = [
      emacsPackage
      pkgs.coreutils
    ];
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    # Test only the startup adapter, without interactive Emacs
    # or the complete user configuration.
    timeout --kill-after=3s 20s \
      ${lib.getExe' emacsPackage "emacs"} --batch -Q \
        --load ${../../lisp/emarccs-bootstrap.el} \
        --load ${./lisp/startup-order.el} \
        --funcall ert-run-tests-batch-and-exit

    touch "$out"
  ''
