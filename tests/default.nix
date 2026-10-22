{
  pkgs,
  packages,
  lib,
}:
lib.concatMapAttrs (
  name_: emacsPackage:
  let
    epkgs_ = emacsPackage.emacs.pkgs;
    configurationPackage = epkgs_.emarccs;
  in
  lib.mapAttrs'
    (checkName_: check_: {
      name = "${name_}-${checkName_}";
      value = check_;
    })
    {
      elisp-byte-compile = pkgs.callPackage ./elisp-byte-compile {
        inherit emacsPackage configurationPackage;
      };

      package-lint = pkgs.callPackage ./package-lint { inherit emacsPackage configurationPackage; };

      startup-smoke = pkgs.callPackage ./startup-smoke { inherit emacsPackage configurationPackage; };

      startup-order = pkgs.callPackage ./startup-order { inherit emacsPackage configurationPackage; };

      package-availability-smoke = pkgs.callPackage ./package-availability-smoke {
        inherit emacsPackage configurationPackage;
      };

      treesit-grammars-runtime = pkgs.callPackage ./treesit-grammars-runtime {
        inherit emacsPackage;
        grammarPackage = epkgs_.treesit-grammars.with-all-grammars;
      };
    }
) packages
