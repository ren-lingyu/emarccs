{
  lib,
  fetchFromGitHub,
  melpaBuild,
  org,
  nix-update-script,
}:
melpaBuild (finalAttrs_: {
  src = fetchFromGitHub {
    owner = "yibie";
    repo = "org-workbench";
    rev = "5091a1d9042b7409e8757b423280b2bff0919b28";
    hash = "sha256-dyu1I+QXHn8ps/JlT6jKFGKmvSLgplcx2PgVcjx3xdQ=";
  };

  pname = finalAttrs_.src.repo;
  version = "0-unstable-2025-11-18";
  melpaVersion = "0.3.0";

  files = "(:defaults)";

  packageRequires = [ org ];

  patches = [ ./fix-byte-compile-warnings.patch ];

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
