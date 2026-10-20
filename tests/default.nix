{
  pkgs,
  lib,
  emacsPackage,
  elispSource,
  elispPackages,
  siteStartCheckList,
}:
{

  elisp-byte-compile = import ./elisp-byte-compile {
    inherit
      pkgs
      lib
      emacsPackage
      elispSource
      ;
  };

  startup-smoke = import ./startup-smoke {
    inherit
      pkgs
      lib
      emacsPackage
      siteStartCheckList
      ;
  };

  startup-order = import ./startup-order { inherit pkgs lib emacsPackage; };

  package-availability-smoke = import ./package-availability-smoke {
    inherit
      pkgs
      lib
      emacsPackage
      elispPackages
      ;
  };

  treesit-grammars-runtime = import ./treesit-grammars-runtime { inherit pkgs lib emacsPackage; };

}
