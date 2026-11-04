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

  postPatch = ''
    cp ${
      fetchFromGitHub {
        owner = "citation-style-language";
        repo = "locales";
        rev = "8bef426f89f38c0789223c50e53ec2197bc50bb3";
        hash = "sha256-hitOVgBD3/WSJrPLVY/xay+Bmvn4HXv5bn64FhNoXcA=";
      }
    }/locales-*.xml etc/csl/
    printf '%s\n' \
      'Additional CSL locales: https://citationstyles.org/ (CC BY-SA 3.0).' \
      >> etc/csl/README
  '';

  meta = {
    homepage = "https://orgmode.org";
    license = [
      lib.licenses.gpl3Plus
      lib.licenses.cc-by-sa-30
    ];
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=main"
    ];
  };
})
