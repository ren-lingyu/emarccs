{ pkgs, lib } : {

  input = final_ : super_ : {
    preBuild = builtins.concatStringsSep ("\n") [
      "export EMARCCS_ORG_GIT_VERSION=\"${builtins.substring 0 8 (super_.src.rev or "unknown")}\""
      "${pkgs.lib.getExe' pkgs.emacs "emacs"} --batch -Q --load ${./pre-build.el}"
    ];
  };

}
