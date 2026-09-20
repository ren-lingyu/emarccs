{ pkgs, lib } : {

  scope = {
    overrideAttrs = { old, ... } : {
      preBuild = builtins.concatStringsSep "\n" [
        "export HOME=\"$TMPDIR/home\""
        "mkdir -p \"$HOME\""
        (old.preBuild or "")
      ];
    };
  };

}
