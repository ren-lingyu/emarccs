{
  runCommand,
  lib,
  emacsPackage,
  overlayPackage,
}:
assert lib.assertMsg (
  overlayPackage.drvPath == emacsPackage.drvPath
) "The default overlay does not produce the expected derivation for ${emacsPackage.name}.";
runCommand "${emacsPackage.name}-overlay-equivalence" { } ''
  touch "$out"
''
