{

  description = "aRenCoco's Emacs configuration and packages built with Nixpkgs";

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

  outputs =
    { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;

        specialArgs =
          let
            lib = inputs.nixpkgs.lib;
          in
          rec {
            llib = lib.mergeAttrsList [
              { elisp = inputs.nix-to-lisp.lib.elisp; }
              (import ./lib { inherit lib; })
            ];
            lpkgs = import ./pkgs { inherit lib llib; };
          };
      }
      (
        {
          llib,
          lpkgs,
          config,
          lib,
          ...
        }@toplevel:
        {
          imports = [
            inputs.treefmt-nix.flakeModule
            inputs.flake-parts.flakeModules.easyOverlay
          ];

          config = {
            systems = inputs.nixpkgs.lib.systems.flakeExposed;

            perSystem =
              {
                inputs',
                config,
                pkgs,
                lib,
                ...
              }:
              {
                _module.args.pkgs = inputs'.nixpkgs.legacyPackages.appendOverlays [ lpkgs.overlays.default ];

                legacyPackages = lpkgs.mkLegacyPackages pkgs;

                packages =
                  builtins.mapAttrs
                    (
                      name_: emacs_:
                      ((pkgs.emacsPackagesFor emacs_).withPackages (epkgs_: [
                        epkgs_.emarccs
                        pkgs.coreutils
                      ])).overrideAttrs
                        (old_: {
                          deps = old_.deps.overrideAttrs (
                            deps_old_:
                            let
                              marker_ = builtins.concatStringsSep "\n" [
                                "cat >\"$subdirs\" <<EOF"
                                ";;; -*- lexical-binding: t -*-"
                                "EOF"
                              ];
                              injection_ = builtins.concatStringsSep "\n" [
                                "cat >> \"$siteStart\" <<'EOF'"
                                "(when init-file-user"
                                "  (package-activate-all)"
                                "  (require 'emarccs)"
                                "  (emarccs-initialize-early)"
                                "  (add-hook 'before-init-hook #'emarccs-initialize))"
                                "EOF"
                                ""
                                marker_
                              ];
                            in
                            assert lib.assertMsg (lib.hasInfix marker_ deps_old_.buildCommand)
                              "Unable to locate the Emacs wrapper site-start insertion point.";
                            {
                              buildCommand = builtins.replaceStrings [ marker_ ] [ injection_ ] deps_old_.buildCommand;
                            }
                          );
                        })
                    )
                    {
                      emarccs = pkgs.emacs;
                      emarccs-pgtk = pkgs.emacs-pgtk;
                      emarccs-gtk = pkgs.emacs-gtk;
                    };

                checks = import ./tests {
                  inherit pkgs lib;
                  packages = config.packages;
                };

                overlayAttrs = lib.optionalAttrs (
                  pkgs.stdenv.buildPlatform.system == pkgs.stdenv.hostPlatform.system
                ) config.packages;

                treefmt = {
                  flakeFormatter = true;
                  flakeCheck = true;
                  enableDefaultExcludes = false;
                  projectRootFile = builtins.baseNameOf __curPos.file;
                  settings.excludes = [
                    ".gitignore"
                    "LICENSE"
                    "README.org"
                    "flake.lock"
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
        }
      );
}
