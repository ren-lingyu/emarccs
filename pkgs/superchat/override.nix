{ pkgs, lib } : {

  scope = { old, ... } : let
    requireLineNumber = lib.findUniqueLineNumber "${old.src}/superchat.el" "(require 'subr-x)";
  in {
    patches = (old.patches or []) ++ [
      (pkgs.writeText "emarccs-superchat-transient.patch" (builtins.concatStringsSep "\n" [
        "diff --git a/superchat.el b/superchat.el"
        "--- a/superchat.el"
        "+++ b/superchat.el"
        "@@ -${builtins.toString requireLineNumber},1 +${builtins.toString requireLineNumber},2 @@"
        " (require 'subr-x)"
        "+(require 'transient)"
        ""
      ]))
    ];

    preBuild = builtins.concatStringsSep "\n" [
      "export HOME=\"$TMPDIR/home\""
      "mkdir -p \"$HOME\""
      (old.preBuild or "")
    ];
  };

}
