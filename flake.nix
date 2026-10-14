{

  description = "aRenCoco's Emacs configuration and packages built by twist";

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    };
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
    };
    treefmt-nix = {
      url = "git+https://github.com/numtide/treefmt-nix.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    twist = {
      url = "git+https://github.com/emacs-twist/twist.nix.git?ref=refs/heads/master&shallow=1";
    };
    nix-to-lisp = {
      url = "git+https://github.com/ren-lingyu/nix-to-lisp.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    melpa = {
      url = "git+https://github.com/melpa/melpa.git?ref=refs/heads/master&shallow=1";
      flake = false;
    };
    elpa-gnu = {
      url = "git+https://https.git.savannah.gnu.org/git/elpa/gnu.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
    elpa-nongnu = {
      url = "git+https://https.git.savannah.gnu.org/git/elpa/nongnu.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
  };

  outputs = { self, ... }@inputs : inputs.flake-parts.lib.mkFlake { inherit inputs; } (        {
    config,
    lib,
    ...
  }@toplevel : {

    imports = [
      inputs.treefmt-nix.flakeModule
      inputs.flake-parts.flakeModules.easyOverlay
    ];

    options = {
      context = lib.mkOption {
        type = lib.types.functionTo (
          lib.types.submodule {
            options = {
              elispkgs = lib.mkOption {
                type = lib.types.raw;
              };
              emacsTwists = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.attrsOf (
                    lib.types.submodule {
                      options = {
                        package = lib.mkOption {
                          type = lib.types.package;
                          description = "Base Emacs package.";
                        };
                        lockDir = lib.mkOption {
                          type = lib.types.path;
                          description = "Twist lock directory.";
                        };
                      };
                    }
                  )
                );
              };
            };
          }
        );
      };
    };

    config = {

      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      context = { pkgs, lib, llib } : {
        elispkgs = import ./pkgs { inherit pkgs lib llib; };
        emacsTwists = {
          emacs = let
            lock_ = ./locks/emacs;
          in {
            pgtk = {
              package = pkgs.emacs-pgtk;
              lockDir = lock_;
            };
            gtk = {
              package = pkgs.emacs-gtk;
              lockDir = lock_;
            };
          };
        };
      };

      flake = {

        lib = { lib } : lib.mergeAttrsList [

          {

            elisp = inputs.nix-to-lisp.lib.elisp;

          }

          (import ./lib { inherit lib; })

        ];

      };

      perSystem = { config, pkgs, lib, ... } : let
        llib = self.lib { inherit lib; };
        twistContext_ = toplevel.config.context { inherit pkgs lib llib; };
      in {

        packages = llib.concatMapEmacsTwists (name_ : cfg_ : {
          "${name_}" = (({ elispkgs, elisp, package, lockDir } : ((inputs.twist.lib.makeEnv {
            pkgs = pkgs;
            emacsPackage = package;
            registries = let
              rewriteSavannahGit = name : path : builtins.toFile name (
                builtins.replaceStrings
                  [
                    "https://git.savannah.gnu.org/"
                    "https://git.savannah.nongnu.org/"
                  ]
                  [
                    "https://https.git.savannah.gnu.org/"
                    "https://https.git.savannah.nongnu.org/"
                  ]
                  (builtins.readFile path)
              );
            in [
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
                path = rewriteSavannahGit "gnu-elpa-packages" "${inputs.elpa-gnu}/elpa-packages";
                auto-sync-only = true;
              }
              {
                name = "nongnu";
                type = "elpa";
                path = rewriteSavannahGit "nongnu-elpa-packages" "${inputs.elpa-nongnu}/elpa-packages";
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
                (elisp.quote (elisp.symbol (lib.removeSuffix ".el" (builtins.baseNameOf ./lisp/twist-emacs/emarccs-twist.el))))
              ])
              (elisp.form "advice-add" [
                (elisp.quote (elisp.symbol "startup--load-user-init-file"))
                (elisp.symbol ":around")
                (elisp.form "emarccs-twist--load-user-init-file" [
                  ./early-init.el
                  (elisp.quote (elisp.symbol (lib.removeSuffix ".el" (builtins.baseNameOf ./lisp/share/emarccs-shared.el))))
                ])
              ])
            ];
          }).overrideScope elispkgs.overrides.scope)) {
            elispkgs = twistContext_.elispkgs;
            elisp = llib.elisp;
            package = cfg_.package;
            lockDir = cfg_.lockDir;
          });
        }) twistContext_.emacsTwists;

        overlayAttrs = lib.optionalAttrs (pkgs.stdenv.buildPlatform.system == pkgs.stdenv.hostPlatform.system) config.packages;

        apps = llib.concatMapEmacsTwists (name_ : cfg_ : let
          apps_ = config.packages.${name_}.makeApps {
            lockDirName = lib.removePrefix "${builtins.toString ./.}/" (builtins.toString cfg_.lockDir);
          };
        in {
          "${name_}-lock" = apps_.lock // {
            meta.description = "Generate lock files for ${name_}.";
          };
          "${name_}-update" = apps_.update // {
            meta.description = "Update lock files for ${name_}.";
          };
        }) twistContext_.emacsTwists;

        checks = llib.concatMapEmacsTwists (name_ : cfg_ : (lib.mapAttrs' (
          checkName_ : check_ : {
            name = "${name_}-${checkName_}";
            value = check_;
          }
        ) (import ./tests {
          inherit pkgs lib;
          emacsPackage = config.packages.${name_};
          elispSource = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./early-init.el
              ./init.el
              ./lisp
            ];
          };
          elispPackages = twistContext_.elispkgs.packages;
          siteStartCheckList = [
            "eval-and-compile"
            "${./lisp/twist-emacs}"
            "${./lisp/share}"
            "${lib.removeSuffix ".el" (builtins.baseNameOf ./lisp/twist-emacs/emarccs-twist.el)}"
            "startup--load-user-init-file"
            "${./early-init.el}"
          ];
        }))) twistContext_.emacsTwists;

        treefmt = {
          flakeFormatter = true;
          flakeCheck = false;
          enableDefaultExcludes = false;
          projectRootFile = builtins.baseNameOf __curPos.file;
          settings.excludes = [
            "flake.lock"
            "locks/**"
            ".gitignore"
            "LICENSE"
            "README.org"
          ];
          programs = {
            nixfmt = {
              enable = true;
              package = pkgs.nixfmt;
              width = 100;
              indent = 2;
              strict = true;
            };
          };
        };

      };

    };

  });

}
