{
  lib,
  fetchFromGitHub,
  melpaBuild,
  org,
  org-roam,
  nix-update-script,
}:

melpaBuild (finalAttrs_: {
  src = fetchFromGitHub {
    owner = "ren-lingyu";
    repo = "org-roam-include";
    rev = "ca62c8fb5c23064253877480edb2ba83a2cf2afb";
    hash = "sha256-P2LgO9Fy4wGG+p8Vg1Pp3SY4kO3Xd/yGCpayQho9i/w=";
  };

  pname = finalAttrs_.src.repo;
  version = "0.1.0-unstable-2026-09-10";
  melpaVersion = "0.1.0";

  files = "(:defaults)";

  packageRequires = [
    org
    org-roam
  ];

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/${finalAttrs_.src.owner}/${finalAttrs_.src.repo}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=main"
    ];
  };
})
