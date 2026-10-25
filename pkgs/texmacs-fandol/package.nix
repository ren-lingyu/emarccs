{
  symlinkJoin,
  makeWrapper,
  texmacs,
  fandol,
}:
symlinkJoin {
  name = "texmacs-fandol-${texmacs.version}";
  paths = [ texmacs ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/texmacs" \
      --prefix TEXMACS_FONT_PATH : "${fandol}/fonts/opentype/public/fandol"
  '';

  passthru = { inherit texmacs fandol; };

  meta = texmacs.meta // {
    description = "TeXmacs with Fandol Chinese fonts";
    mainProgram = "texmacs";
  };
}
