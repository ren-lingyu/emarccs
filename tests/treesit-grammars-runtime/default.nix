{
  runCommand,
  coreutils,
  lib,
  emacsPackage,
  grammarPackage,
}:
runCommand "emarccs-treesit-grammars-runtime"
  {
    nativeBuildInputs = [ coreutils ];
    EMARCCS_GRAMMAR_DIRECTORY = "${grammarPackage}/lib";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    timeout --kill-after=3s 60s \
      ${lib.getExe' emacsPackage "emacs"} --batch -q \
        --load ${./lisp/treesit-grammars-runtime.el}
    touch "$out"
  ''
