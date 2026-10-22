{
  lib,
  fetchFromGitHub,
  trivialBuild,
  org,
  nix-update-script,
}:
trivialBuild (finalAttrs_: {
  src = fetchFromGitHub {
    owner = "yibie";
    repo = "org-include-inline";
    rev = "b56bcd6a7297f7453b99ca1ec9bd62bae20bfbe2";
    hash = "sha256-6c+vVdv/97OPIN8Zo8GLMhMM80u2JZdP+JiqF5V0ZJY=";
  };

  pname = finalAttrs_.src.repo;
  version = "0.1.0";

  patches = [ ./fix-byte-compile-warnings.patch ];

  packageRequires = [ org ];

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
