{
  runCommand,
  coreutils,
  diffutils,
  findutils,
  gnugrep,
  texmacs,
}:
runCommand "${texmacs.pname}-resources"
  {
    nativeBuildInputs = [
      coreutils
      diffutils
      findutils
      gnugrep
    ];
  }
  ''
    style=$(find ${texmacs} -path '*/packages/emarccs/emarccs-math.ts' -type f -print)
    test -f "$style"
    cmp ${texmacs.mathStyle} "$style"
    test "$(grep -c '^  <assign|' "$style")" -eq 4417
    grep -Fx '  <assign|lprp|<macro|body|<around*|(|<arg|body>|)>>>' "$style"
    grep -Fx '  <assign|concat-lprp|<xmacro|args|<lprp|<map-args|identity|concat|args>>>>' "$style"
    grep -Fx '  <assign|lpn|<macro|body|<around*|(|<arg|body>|\<nobracket\>>>>' "$style"
    grep -Fx '  <assign|nrp|<macro|body|<around*|\<nobracket\>|<arg|body>|)>>>' "$style"
    grep -Fx '  <assign|l2vr2v|<macro|body|<around*|\<lVert\>|<arg|body>|\<rVert\>>>>' "$style"
    grep -Fx '  <assign|application|<macro|function|argument|<arg|function>\ <arg|argument>>>' "$style"
    if grep -E '^  <assign\|(concat-)?nn\|' "$style"; then
      echo "Unexpected invisible-invisible delimiter macro" >&2
      exit 1
    fi

    resources="''${style%/packages/emarccs/emarccs-math.ts}"
    for font in ${texmacs.fandol}/fonts/opentype/public/fandol/*.otf; do
      cmp "$font" "$resources/fonts/truetype/fandol/$(basename "$font")"
    done

    mkdir -p "$out"
    cp "$style" "$out/emarccs-math.ts"
  ''
