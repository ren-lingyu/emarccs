{ pkgs, lib } : {

  scope = { old, ... } : let
    requireLineNumber = lib.findUniqueLineNumber "${old.src}/citar.el" "(require 'cl-lib)";
  in {
    patches = (old.patches or []) ++ [
      (pkgs.writeText "emarccs-citar-autoload.patch" (builtins.concatStringsSep "\n" [
        "diff --git a/citar.el b/citar.el"
        "--- a/citar.el"
        "+++ b/citar.el"
        "@@ -${builtins.toString requireLineNumber},1 +${builtins.toString requireLineNumber},2 @@"
        "+;;;###autoload"
        " (require 'cl-lib)"
        ""
      ]))
    ];
  };

}
