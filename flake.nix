{
  
  description = "aRenCoco's Emacs configuration and packages built by twist";
  
  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixos-unstable&shallow=1";
    };
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
    };
    twist = {
      url = "git+https://github.com/emacs-twist/twist.nix.git?ref=refs/heads/master&shallow=1";
      inputs.elisp-helpers.url = "git+https://github.com/emacs-twist/elisp-helpers?ref=refs/heads/master&shallow=1";
    };
    nix-to-lisp = {
      url = "git+https://github.com/ren-lingyu/nix-to-lisp.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    melpa = {
      url = "git+https://github.com/melpa/melpa.git?ref=refs/heads/master&shallow=1";
      flake = false;
    };
    elpa-gnu = {
      url = "git+https://git.savannah.gnu.org/git/elpa/gnu.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
    elpa-nongnu = {
      url = "git+https://git.savannah.gnu.org/git/elpa/nongnu.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
  };
  
  outputs = { self, ... }@inputs : inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    
    systems = inputs.nixpkgs.lib.systems.flakeExposed;
    
    flake = {
      
      lib = {
        
        elisp = inputs.nix-to-lisp.lib.elisp;
        
        concatMapEmacsTwists = pkgs_ : f_ : emacsTwists_ : (pkgs_.lib.concatMapAttrs (emacsName_ : variants_ : (
          pkgs_.lib.concatMapAttrs (variantName_ : cfg_ : let
            name_ = "${emacsName_}-${variantName_}-twist";
          in (f_ name_ emacsName_ variantName_ cfg_)) variants_)
        ) emacsTwists_);
        
        mkEmacsTwist = { pkgs, elispkgs, elisp, package, lockDir } : (inputs.twist.lib.makeEnv {
          pkgs = pkgs;
          emacsPackage = package;
          registries = [
            {
              name = "emarccs-recipes";
              type = "melpa";
              path = "${elispkgs.recipes.melpa}";
            }
            {
              name = "melpa";
              type = "melpa";
              path = "${inputs.melpa}/recipes";
            }
            {
              name = "gnu";
              type = "elpa";
              path = "${inputs.elpa-gnu}/elpa-packages";
              auto-sync-only = true;
            }
            {
              name = "nongnu";
              type = "elpa";
              path = "${inputs.elpa-nongnu}/elpa-packages";
            }
          ];
          extraPackages = elispkgs.packages;
          inputOverrides = elispkgs.overrides.input;
          initFiles = [];
          initParser = _ : {
            elispPackages = [];
            elispPackagePins = {};
            systemPackages = [];
          };
          lockDir = lockDir;
          nativeCompileAheadDefault = true;
          extraSiteStartElisp = elisp.renderForms [
            (elisp.form "eval-and-compile" [
              (elisp.form "add-to-list" [
                (elisp.quote (elisp.symbol "load-path"))
                ./lisp/twist-emacs
              ])
              (elisp.form "add-to-list" [
                (elisp.quote (elisp.symbol "load-path"))
                ./lisp/share
              ])
            ])
            (elisp.form "require" [
              (elisp.quote (elisp.symbol (pkgs.lib.removeSuffix ".el" (builtins.baseNameOf ./lisp/twist-emacs/emarccs-twist.el))))
            ])
            (elisp.form "advice-add" [
              (elisp.quote (elisp.symbol "startup--load-user-init-file"))
              (elisp.symbol ":around")
              (elisp.form "emarccs-twist--load-user-init-file" [
                ./early-init.el
                (elisp.quote (elisp.symbol (pkgs.lib.removeSuffix ".el" (builtins.baseNameOf ./lisp/share/emarccs-shared.el))))
              ])
            ])
          ];
        }).overrideScope elispkgs.overrides.scope;
        
      };
      
    };
    
    perSystem = { config, pkgs, ... } : let
      
      elispkgs = (import ./pkgs { inherit pkgs; });
      
      emacsTwists = {
        emacs = let
          lock_ = ./locks/emacs;
        in {
          pgtk = {
            package = pkgs.emacs31-pgtk;
            lockDir = lock_;
          };
          gtk = {
            package = pkgs.emacs31-gtk3;
            lockDir = lock_;
          };
        };
      };
      
    in {
      
      packages = self.lib.concatMapEmacsTwists pkgs (name_ : emacsName_ : variantName_ : cfg_ : {
        "${name_}" = self.lib.mkEmacsTwist {
          inherit pkgs elispkgs;
          elisp = self.lib.elisp;
          package = cfg_.package;
          lockDir = cfg_.lockDir;
        };
      }) emacsTwists;
      
      apps = self.lib.concatMapEmacsTwists pkgs (name_ : emacsName_ : variantName_ : cfg_ : let
        apps_ = config.packages.${name_}.makeApps {
          lockDirName = pkgs.lib.removePrefix "${builtins.toString ./.}/" (builtins.toString cfg_.lockDir);
        };
      in {
        "${name_}-lock" = apps_.lock // {
          meta.description = "Generate lock files for ${name_}.";
        };
        "${name_}-update" = apps_.update // {
          meta.description = "Update lock files for ${name_}.";
        };
      }) emacsTwists;
      
      checks = self.lib.concatMapEmacsTwists pkgs (name_ : emacsName_ : variantName_ : cfg_ : (pkgs.lib.mapAttrs' (
        checkName_ : check_ : {
          name = "${name_}-${checkName_}";
          value = check_;
        }
      ) (import ./tests {
        inherit pkgs;
        emacsPackage = config.packages.${name_};
        elispPackages = elispkgs.packages;
        siteStartCheckList = [
          "eval-and-compile"
          "${./lisp/twist-emacs}"
          "${./lisp/share}"
          "${pkgs.lib.removeSuffix ".el" (builtins.baseNameOf ./lisp/twist-emacs/emarccs-twist.el)}"
          "startup--load-user-init-file"
          "${./early-init.el}"
        ];
      }))) emacsTwists;
      
    };
    
  };
  
}
