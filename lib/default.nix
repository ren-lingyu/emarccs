{ lib }: {
  mkMelpaBuild = import ./mkMelpaBuild.nix;
  tests.withProgress = import ./withProgress.nix { inherit lib; };
}
