{
  runCommand,
  lib,
  emacsPackage,
  grammarPackage,
}:
runCommand "emarccs-treesit-grammars-runtime"
  { EMARCCS_GRAMMAR_DIRECTORY = "${grammarPackage}/lib"; }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ${lib.getExe' emacsPackage "emacs"} --batch -q --load ${./lisp/treesit-grammars-runtime.el}
    touch "$out"
  ''
