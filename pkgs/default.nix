{ pkgs } : let
  
  mkMelpaRecipes = x_ : (
    pkgs.runCommand "emarccs-melpa-recipes" {} (
      builtins.concatStringsSep "\n" (builtins.concatLists [
        [ "mkdir -p $out" ]
        (builtins.map (name_ : "cp ${x_.${name_}} $out/${name_}") (builtins.attrNames x_))
      ])
    )
  );

  mkAttrSetFromDirectory = filterFileName_ : attrFun_ : let
    rootDir_ = ./.;
    dirAttrSet_ = builtins.readDir rootDir_;
    dirAttrNames_ = builtins.attrNames dirAttrSet_;
  in (builtins.listToAttrs (builtins.map (
    name_ : {
      name = name_;
      value = attrFun_ (rootDir_ + "/${name_}/${filterFileName_ name_}");
    }
  ) (builtins.filter (
    x_ : (
      dirAttrSet_.${x_} == "directory" && builtins.pathExists (rootDir_ + "/${x_}/${filterFileName_ x_}")
    )
  ) dirAttrNames_)));

in {
  
  packages = [
    "aas"
    "ace-window"
    "arxiv-mode"
    "auctex"
    "avy"
    "catppuccin-theme"
    "cdlatex"
    "citar"
    "citar-embark"
    "citar-org-roam"
    "citeproc"
    "company"
    "company-auctex"
    "company-math"
    "consult"
    "consult-org-roam"
    "counsel"
    "dired-rainbow"
    "diredfl"
    "dirvish"
    "dockerfile-mode"
    "doom-modeline"
    "doom-themes"
    "dotenv-mode"
    "elfeed"
    "elfeed-dashboard"
    "elfeed-org"
    "ellama"
    "embark"
    "embark-consult"
    "flycheck"
    "gptel"
    "helpful"
    "highlight-parentheses"
    "hl-block-mode"
    "hl-indent-scope"
    "kdl-mode"
    "koishi-theme"
    "laas"
    "lisp-semantic-hl"
    "marginalia"
    "markdown-mode"
    "modus-themes"
    "neotree"
    "nerd-icons"
    "nix-mode"
    "nix-ts-mode"
    "orderless"
    "org"
    "org-edna" # Transitive dependency
    "org-gtd"
    "org-include-inline"
    "org-roam"
    "org-roam-organize"
    "org-roam-timestamps"
    "org-roam-ui"
    "org-transclusion"
    "org-workbench"
    "powerline"
    "pyim"
    "pyim-basedict"
    "pyim-cangjiedict"
    "qml-mode"
    "queue" # Transitive dependency
    "rainbow-delimiters"
    "ripgrep"
    "superchat"
    "transient"
    "treesit-auto"
    "undo-tree"
    "vertico"
    "vlf"
    "vundo"
    "yaml-mode"
    "yasnippet"
  ];

  recipes = {
    melpa = mkMelpaRecipes (mkAttrSetFromDirectory (x_ : "melpa-recipe.el") (x_ : x_));
  };
  
  overrides = let
    allOverrides_ = mkAttrSetFromDirectory (x_ : "override.nix") (x_ : (import x_ { inherit pkgs; }));
  in {
    
    input = pkgs.lib.mapAttrs (_ : x_ : x_.input) (
      pkgs.lib.filterAttrs (_ : x_ : x_ ? input) allOverrides_
    );
    
    scope = final_ : prev_ : {
      elispPackages = prev_.elispPackages.overrideScope (
        efinal_ : esuper_ : pkgs.lib.mapAttrs (
          name_ : x_ : esuper_.${name_}.overrideAttrs (
            old_ : x_.scope {
              final = final_;
              prev = prev_;
              efinal = efinal_;
              esuper = esuper_;
              old = old_;
            }
          )
        ) (
          pkgs.lib.filterAttrs (_ : x_ : x_ ? scope) allOverrides_
        )
      );
    };
    
  };
  
}
