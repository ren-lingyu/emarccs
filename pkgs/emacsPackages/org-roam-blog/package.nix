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
    repo = "org-roam-blog";
    rev = "778d410f55710bca22a2d84a301a72b7b099b874";
    hash = "sha256-DozMZhIUtEfb2MXjjTor1SIsvIRz6yqWo4oB+vsmuso=";
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
