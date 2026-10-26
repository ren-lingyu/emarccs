{
  description = "aRenCoco's Emacs configuration and packages built with Nixpkgs";

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    };
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        local-nixpkgs.url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=refs/heads/main&shallow=1&dir=pkgs";
      };
    };
    org-texmacs = {
      url = "git+https://github.com/ren-lingyu/org-texmacs.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.personal-nixpkgs.lib.mkFlake inputs.nixpkgs
      ({ lib }: rec {
        inherit inputs;
        moduleLocation = __curPos.file;
        llib = inputs.personal-nixpkgs.lib.mergeAttrsRecursive { allowOverrides = false; } [
          { inherit (inputs.personal-nixpkgs.lib) tests packages; }
          (import ./lib { inherit lib; })
        ];
        lpkgs = import ./pkgs { inherit lib llib; };
      })
      (
        {
          llib,
          lpkgs,
          config,
          lib,
          ...
        }@toplevel:
        {
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
                nixpkgs.overlays = [ lpkgs.overlays.legacy ];

                legacyPackages = pkgs.legacyPackages;

                packages = { inherit (pkgs) emarccs emarccs-pgtk emarccs-gtk; };

                checks = import ./tests {
                  inherit pkgs lib llib;
                  packages = config.packages;
                  overlay = toplevel.config.flake.overlays.default;
                };

                treefmt = {
                  flakeCheck = true;
                  settings.excludes = [
                    "*.patch"
                    ".gitignore"
                    "LICENSE"
                    "README.org"
                    "flake.lock"
                  ];
                };
              };
          };
        }
      );
}
