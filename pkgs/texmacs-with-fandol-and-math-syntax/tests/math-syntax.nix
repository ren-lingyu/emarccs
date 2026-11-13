{
  lib,
  runCommand,
  coreutils,
  diffutils,
  gnugrep,
  poppler-utils,
  writeText,
  texmacs,
}:
runCommand "${texmacs.pname}-math-syntax"
  {
    nativeBuildInputs = [
      coreutils
      diffutils
      gnugrep
      poppler-utils
    ];

    actualDocument = writeText "actual.tm" ''
      <TeXmacs|2.1.5>

      <style|<tuple|generic|emarccs-math>>

      <\body>
        MathSyntaxSmoke

        <\equation*>
          <application|f|<concat-lprp|<lprp|x>|+|<lpn|y>>>
        </equation*>

        <\equation*>
          <l2vr2v|<frac|a|b>>+<nrp|z>
        </equation*>
      </body>
    '';

    referenceDocument = writeText "reference.tm" ''
      <TeXmacs|2.1.5>

      <style|generic>

      <\body>
        MathSyntaxSmoke

        <\equation*>
          f\ <around*|(|<around*|(|x|)>+<around*|(|y|\<nobracket\>>|)>
        </equation*>

        <\equation*>
          <around*|\<lVert\>|<frac|a|b>|\<rVert\>>+<around*|\<nobracket\>|z|)>
        </equation*>
      </body>
    '';
  }
  ''
    export HOME="$TMPDIR/home"
    export QT_QPA_PLATFORM=offscreen
    mkdir -p "$HOME"
    cp "$actualDocument" actual.tm
    cp "$referenceDocument" reference.tm

    for name in actual reference; do
      export TEXMACS_HOME_PATH="$HOME/$name"
      mkdir -p "$TEXMACS_HOME_PATH"
      export EMARCCS_TM_INPUT="$PWD/$name.tm"
      export EMARCCS_PDF_OUTPUT="$PWD/$name.pdf"
      timeout --kill-after=5s 180s \
        ${lib.getExe' texmacs "texmacs"} -H -s -x '(load "${./render.scm}")' \
        > "$name.log" 2>&1 || { cat "$name.log"; exit 1; }
      grep -F 'EMARCCS-RENDER-OK' "$name.log" || { cat "$name.log"; exit 1; }
      test -s "$name.pdf"
      pdftotext -layout "$name.pdf" "$name.txt"
      grep -F 'MathSyntaxSmoke' "$name.txt"
      test "$(pdfinfo "$name.pdf" | grep -Ec '^Pages:[[:space:]]+1$')" -eq 1
      pdftoppm -r 120 -singlefile "$name.pdf" "$name"
    done

    cmp actual.txt reference.txt
    cmp actual.ppm reference.ppm
    mkdir -p "$out"
    cp actual.{tm,pdf,txt,ppm,log} reference.{tm,pdf,txt,ppm,log} "$out/"
  ''
