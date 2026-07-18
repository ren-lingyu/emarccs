{ pkgs, emacsPackage, elispPackages, siteStartCheckList } : {

  startup-smoke = import ./startup-smoke {
    inherit pkgs emacsPackage siteStartCheckList;
  };

  package-availability-smoke = import ./package-availability-smoke {
    inherit pkgs emacsPackage elispPackages;
  };

  treesit-grammars-runtime = import ./treesit-grammars-runtime {
    inherit pkgs emacsPackage;
  };

}
