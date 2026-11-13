{
  lib,
  callPackage,
  withProgress,
  writeText,
  texmacs,
  fandol,
}:
texmacs.overrideAttrs (
  finalAttrs: old: {
    pname = "texmacs-with-fandol-and-math-syntax";

    postPatch = (old.postPatch or "") + ''
      install -Dm644 ${finalAttrs.passthru.mathStyle} \
        TeXmacs/packages/emarccs/emarccs-math.ts

      install -Dm644 -t TeXmacs/fonts/truetype/fandol \
        ${fandol}/fonts/opentype/public/fandol/*.otf
    '';

    passthru = lib.mergeAttrsList [
      (old.passthru or { })
      {
        inherit fandol;
        mathStyle = writeText "emarccs-math.ts" (import ./math { inherit lib; });

        tests = lib.mergeAttrsList [
          (old.passthru.tests or { })
          {
            resources = callPackage ./tests/resources.nix {
              inherit withProgress;
              texmacs = finalAttrs.finalPackage;
            };
            math-syntax = callPackage ./tests/math-syntax.nix {
              inherit withProgress;
              texmacs = finalAttrs.finalPackage;
            };
          }
        ];
      }
    ];

    meta = lib.mergeAttrsList [
      old.meta
      {
        description = "TeXmacs with Fandol Chinese fonts and Emarccs mathematical syntax";
        mainProgram = "texmacs";
      }
    ];
  }
)
