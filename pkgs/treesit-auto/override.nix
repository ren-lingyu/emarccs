{ pkgs } : {

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
    sourceLines = pkgs.lib.splitString "\n" (builtins.readFile "${old.src}/treesit-auto.el");
    matchingLineNumbers = let
      go = lineNumber : lines : (
        if lines == [] then []
        else (
          (if builtins.head lines == "(provide 'treesit-auto)" then [ lineNumber ] else [])
          ++ (go (lineNumber + 1) (builtins.tail lines))
        )
      );
    in (go 1 sourceLines);
    provideLineNumber = (
      if builtins.length matchingLineNumbers == 1 then builtins.head matchingLineNumbers
      else throw "Expected exactly one (provide 'treesit-auto) line in treesit-auto.el"
    );
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
