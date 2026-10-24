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
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
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
            llib = inputs.personal-nixpkgs.lib.mergeAttrsRecursive { allowOverrides = false; } [
              { inherit (inputs.personal-nixpkgs.lib) tests packages; }
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
          imports = [ inputs.treefmt-nix.flakeModule ];

          config = {
            systems = inputs.nixpkgs.lib.systems.flakeExposed;

            flake.overlays.default = lpkgs.overlays.default;

            perSystem =
              {
                system,
                config,
                pkgs,
                lib,
                ...
              }:
              {
                _module.args.pkgs = import inputs.nixpkgs {
                  inherit system;
                  overlays = [ lpkgs.overlays.legacy ];
                };

                legacyPackages = pkgs.legacyPackages;

                packages = { inherit (pkgs) emarccs emarccs-pgtk emarccs-gtk; };

                checks = import ./tests {
                  inherit pkgs lib llib;
                  packages = config.packages;
                  overlay = toplevel.config.flake.overlays.default;
                };

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
