{
  runCommand,
  lib,
  withProgress,
  emacsPackage,
  grammarPackage,
}:
runCommand "emarccs-treesit-grammars-runtime"
  { EMARCCS_GRAMMAR_DIRECTORY = "${grammarPackage}/lib"; }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ${withProgress {
      name = "grammars-runtime";
      text = ''
        ${lib.getExe' emacsPackage "emacs"} --batch -q --load ${./lisp/treesit-grammars-runtime.el}
      '';
    }}
    touch "$out"
  ''
