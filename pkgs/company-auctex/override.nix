{ pkgs, lib } : {

  input = final_ : super_ : {
    preBuild = builtins.concatStringsSep "\n" [
      (super_.preBuild or "")
      "export HOME=\"$TMPDIR/home\""
      "mkdir -p \"$HOME\""
    ];
  };

}
