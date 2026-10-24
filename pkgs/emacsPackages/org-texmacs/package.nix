{
  lib,
  fetchFromGitHub,
  melpaBuild,
  org,
  texmacs,
  nix-update-script,
}:
melpaBuild (finalAttrs_: {
  src = fetchFromGitHub {
    owner = "ren-lingyu";
    repo = "org-texmacs";
    rev = "2c1c7d58fb30ea177e2a6f78ee1857c8fcfb9231";
    hash = "sha256-bgiTykAV3xy7LKW7Dl9Q+Nm9MdanWtCH9I5Odhh9Y1c=";
  };

  pname = finalAttrs_.src.repo;
  version = "0.4.0-unstable-2026-10-18";
  melpaVersion = "0.5.0";

  files = ''(:defaults "org-texmacs-worker.scm")'';

  packageRequires = [ org ];

  turnCompilationWarningToError = true;

  postPatch = builtins.concatStringsSep " " [
    "substituteInPlace org-texmacs-core.el"
    "--replace-fail"
    "'(defcustom org-texmacs-program \"texmacs\"'"
    "'(defcustom org-texmacs-program \"${lib.getExe' texmacs "texmacs"}\"'"
  ];

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
