{ pkgs, emacsPackage, siteStartCheckList } : let
  
  minEmacsVersion_ = "31.0";
  
in (
  
  pkgs.runCommand "emarccs-startup-smoke" {
    nativeBuildInputs = [
      emacsPackage
    ];
  } (builtins.concatStringsSep "\n" (builtins.concatLists [
    [
      "site_start=\"${emacsPackage}/share/emacs/site-lisp/site-start.el\""
      "test -f \"$site_start\""
    ]
    (builtins.map (item_ : "grep -Fq \"${item_}\" \"$site_start\"") siteStartCheckList)
    [
      "MIN_EMACS_VERSION=${minEmacsVersion_} ${pkgs.lib.getExe' emacsPackage "emacs"} --batch --load ${./lisp/startup-smoke.el}"
      "touch \"$out\""
    ]
  ]))
    
)
