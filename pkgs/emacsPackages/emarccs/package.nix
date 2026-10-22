{
  lib,
  melpaBuild,

  aas,
  ace-window,
  arxiv-mode,
  auctex,
  avy,
  catppuccin-theme,
  cdlatex,
  citar,
  citar-embark,
  citar-org-roam,
  citeproc,
  company,
  company-auctex,
  company-math,
  consult,
  counsel,
  diff-hl,
  dired-rainbow,
  diredfl,
  dirvish,
  dockerfile-mode,
  doom-modeline,
  doom-themes,
  dotenv-mode,
  elfeed,
  elfeed-dashboard,
  elfeed-org,
  embark,
  embark-consult,
  flycheck,
  haskell-ts-mode,
  helpful,
  highlight-parentheses,
  hl-block-mode,
  hl-indent-scope,
  kdl-mode,
  koishi-theme,
  laas,
  lisp-semantic-hl,
  marginalia,
  markdown-mode,
  modus-themes,
  neotree,
  nerd-icons,
  nix-mode,
  nix-ts-mode,
  orderless,
  org,
  org-edna,
  org-gtd,
  org-include-inline,
  org-roam,
  org-roam-blog,
  org-roam-include,
  org-roam-organize,
  org-roam-timestamps,
  org-roam-ui,
  org-texmacs,
  org-transclusion,
  org-workbench,
  pdf-tools,
  powerline,
  pyim,
  pyim-basedict,
  pyim-cangjiedict,
  qml-mode,
  rainbow-delimiters,
  ripgrep,
  sly,
  treesit-auto,
  undo-tree,
  vertico,
  vlf,
  vundo,
  yaml-mode,
  yasnippet,
}@args:

melpaBuild (finalAttrs_: {
  src = ./lisp;

  pname = "emarccs";
  version = "0.1.0";
  melpaVersion = "0.1.0";

  files = "(:defaults)";

  packageRequires = builtins.attrValues (
    builtins.removeAttrs args [
      "lib"
      "melpaBuild"
    ]
  );

  turnCompilationWarningToError = false;
})
