{ }:
final_: prev_:
let
  # Resolve system programs outside the Emacs package scope.
  pkgs = final_.callPackage ({ pkgs }: pkgs) { };
in
{
  ripgrep = prev_.ripgrep.overrideAttrs (old_: {
    propagatedUserEnvPkgs = builtins.concatLists [
      (old_.propagatedUserEnvPkgs or [ ])
      [ pkgs.ripgrep ]
    ];
  });
}
