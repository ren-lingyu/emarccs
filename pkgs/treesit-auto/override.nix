{ pkgs, lib } : {

  scope = { old, ... } : let
    treesitGrammars = pkgs.emacs.pkgs.treesit-grammars.with-grammars (grammars : with grammars; [
      tree-sitter-bash
      tree-sitter-c
      tree-sitter-cmake
      tree-sitter-cpp
      tree-sitter-css
      tree-sitter-dockerfile
      tree-sitter-html
      tree-sitter-javascript
      tree-sitter-json
      tree-sitter-markdown
      tree-sitter-nix
      tree-sitter-python
      tree-sitter-rust
      tree-sitter-toml
      tree-sitter-tsx
      tree-sitter-typescript
      tree-sitter-yaml
    ]);
    provideLineNumber = lib.findUniqueLineNumber "${old.src}/treesit-auto.el" "(provide 'treesit-auto)";
  in {
    patches = (old.patches or []) ++ [
      (pkgs.writeText "emarccs-treesit-auto-grammars.patch" (builtins.concatStringsSep "\n" [
        "diff --git a/treesit-auto.el b/treesit-auto.el"
        "--- a/treesit-auto.el"
        "+++ b/treesit-auto.el"
        "@@ -${builtins.toString provideLineNumber},2 +${builtins.toString provideLineNumber},3 @@"
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-extra-load-path \"${treesitGrammars}/lib\"))"
        " (provide 'treesit-auto)"
        " ;;; treesit-auto.el ends here"
        ""
      ]))
    ];
  };

}
