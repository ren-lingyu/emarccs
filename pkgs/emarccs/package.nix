{
  lib,
  emacs,
  emacsPackagesFor,
  coreutils,
}:

((emacsPackagesFor emacs).withPackages (epkgs_: [
  epkgs_.emarccs
  coreutils
])).overrideAttrs
  (old_: {
    deps = old_.deps.overrideAttrs (
      deps_old_:
      let
        marker_ = builtins.concatStringsSep "\n" [
          "cat >\"$subdirs\" <<EOF"
          ";;; -*- lexical-binding: t -*-"
          "EOF"
        ];
        injection_ = builtins.concatStringsSep "\n" [
          "cat >> \"$siteStart\" <<'EOF'"
          "(when init-file-user"
          "  (package-activate-all)"
          "  (require 'emarccs)"
          "  (emarccs-initialize-early)"
          "  (add-hook 'before-init-hook #'emarccs-initialize))"
          "EOF"
          ""
          marker_
        ];
      in
      assert lib.assertMsg (lib.hasInfix marker_ deps_old_.buildCommand)
        "Unable to locate the Emacs wrapper site-start insertion point.";
      {
        buildCommand = builtins.replaceStrings [ marker_ ] [ injection_ ] deps_old_.buildCommand;
      }
    );
  })
