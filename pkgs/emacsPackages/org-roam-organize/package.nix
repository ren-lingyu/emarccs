{
  lib,
  fetchFromGitHub,
  trivialBuild,
  org,
  org-roam,
  nix-update-script,
}:

trivialBuild (finalAttrs_: {
  src = fetchFromGitHub {
    owner = "ren-lingyu";
    repo = "org-roam-organize";
    rev = "eaaee8e47137e4bebc65b3cce6b7c409bc5a24cd";
    hash = "sha256-CjK3hO/Fawktnb5ddJLy/0SySSlZmQ4lqNUT/AxO5JA=";
  };

  pname = finalAttrs_.src.repo;
  version = "0.7.0";

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
