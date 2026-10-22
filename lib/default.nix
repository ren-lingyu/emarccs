{ lib }: {

  packages = import ./packages.nix { inherit lib; };

}
