{ pkgs, lib } : {

  scope = { old, ... } : let
    treesitGrammars = pkgs.emacs.pkgs.treesit-grammars.with-all-grammars;
    provideLineNumber = lib.findUniqueLineNumber "${old.src}/treesit-auto.el" "(provide 'treesit-auto)";
  in {
    patches = (old.patches or []) ++ [
      (pkgs.writeText "emarccs-treesit-auto-grammars.patch" (builtins.concatStringsSep "\n" [
        "diff --git a/treesit-auto.el b/treesit-auto.el"
        "--- a/treesit-auto.el"
        "+++ b/treesit-auto.el"
        "@@ -${builtins.toString provideLineNumber},2 +${builtins.toString provideLineNumber},11 @@"
        # Make Nix-managed grammars visible to Emacs at runtime.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-extra-load-path \"${treesitGrammars}/lib\"))"
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(dtd \"libtree-sitter-dtd\" \"tree_sitter_xml\")))" # Shares the xml init symbol.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(go-template \"libtree-sitter-go-template\" \"tree_sitter_gotmpl\")))" # Uses tree_sitter_gotmpl, not Emacs' default tree_sitter_go_template.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(go-template-helm \"libtree-sitter-go-template-helm\" \"tree_sitter_helm\")))" # Shares the helm init symbol.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(ocaml-interface \"libtree-sitter-ocaml-interface\" \"tree_sitter_ocaml\")))" # Shares the ocaml init symbol.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(org-nvim \"libtree-sitter-org-nvim\" \"tree_sitter_org\")))" # Shares the org init symbol.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(php-only \"libtree-sitter-php-only\" \"tree_sitter_php\")))" # Shares the php init symbol.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(sshclientconfig \"libtree-sitter-sshclientconfig\" \"tree_sitter_ssh_client_config\")))" # Uses underscores in the init symbol.
        "+(with-eval-after-load 'treesit (add-to-list 'treesit-load-name-override-list '(tsx \"libtree-sitter-tsx\" \"tree_sitter_typescript\")))" # Shares the typescript init symbol.
        " (provide 'treesit-auto)"
        " ;;; treesit-auto.el ends here"
        ""
      ]))
    ];
  };

}
