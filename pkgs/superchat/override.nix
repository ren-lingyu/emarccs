{ pkgs } : {

  scope = { old, ... } : {
    preBuild = builtins.concatStringsSep "\n" [
      "export HOME=\"$TMPDIR/home\""
      "mkdir -p \"$HOME\""
      "sed -i \"/^(require 'subr-x)$/a (require 'transient)\" superchat.el"
      (old.preBuild or "")
    ];
  };

}
