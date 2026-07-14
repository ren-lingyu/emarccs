{ pkgs } : {

  input = final_ : super_ : {
    preBuild = builtins.concatStringsSep "\n" [
      (super_.preBuild or "")
      "sed -i \"/^(require 'cl-lib)$/i ;;;###autoload\" citar.el"
    ];
  };

}
