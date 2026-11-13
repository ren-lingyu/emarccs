{
  runCommand,
  lib,
  withProgress,
  emacsPackage,
  configurationPackage,
}:
runCommand "emarccs-package-availability-smoke"
  {
    PACKAGE_NAMES = lib.concatStringsSep " " (
      map (package: package.pname) configurationPackage.packageRequires
    );
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ${withProgress {
      name = "package-availability-smoke";
      text = ''
        ${lib.getExe' emacsPackage "emacs"} --batch -q --load ${./lisp/package-availability-smoke.el}
      '';
    }}
    touch "$out"
  ''
