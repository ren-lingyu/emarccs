{
  runCommand,
  coreutils,
  lib,
  emacsPackage,
  configurationPackage,
}:
runCommand "emarccs-package-availability-smoke"
  {
    nativeBuildInputs = [ coreutils ];
    PACKAGE_NAMES = lib.concatStringsSep " " (
      map (package: package.pname) configurationPackage.packageRequires
    );
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    timeout --kill-after=3s 30s \
      ${lib.getExe' emacsPackage "emacs"} --batch -q \
        --load ${./lisp/package-availability-smoke.el}
    touch "$out"
  ''
