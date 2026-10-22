{
  lib,
  fetchFromGitHub,
  melpaBuild,
  compat,
  gnumake,
  emacs,
  nix-update-script,
}:
melpaBuild (finalAttrs_: {
  src = fetchFromGitHub {
    owner = "bzg";
    repo = "org-mode";
    rev = "38e0eaeec4b1b3482be1afbf77373457bacd93f2";
    hash = "sha256-HB2PKsnQvwhorsUOxcdQhWQCCvJxGDHFabTMl8/OZo4=";
  };

  pname = "org";
  version = "release_9.8.12-unstable-2026-10-21";
  melpaVersion = "10.0pre";

  commit = finalAttrs_.src.rev;

  files = "(:defaults \"etc\")";

  packageRequires = [ compat ];

  nativeBuildInputs = [ gnumake ];

  preBuild = builtins.concatStringsSep "\n" [
    "make autoloads ORGVERSION=10.0-pre GITVERSION=${
      builtins.substring 0 8 finalAttrs_.commit
    } EMACS=${lib.getExe emacs}"
  ];

  meta = {
    homepage = "https://orgmode.org";
    license = lib.licenses.gpl3Plus;
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=main"
    ];
  };
})
