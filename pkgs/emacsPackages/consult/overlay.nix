final_: prev_:
let
  # Resolve system programs outside the Emacs package scope.
  pkgs = final_.callPackage ({ pkgs }: pkgs) { };
in
{
  consult = prev_.consult.overrideAttrs (old_: {
    propagatedUserEnvPkgs = builtins.concatLists [
      (old_.propagatedUserEnvPkgs or [ ])
      [
        pkgs.ripgrep
        pkgs.gnugrep
      ]
    ];
  });
}
