{ pkgs } : {

  scope = { old, ... } : {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
      pkgs.git
      pkgs.perl
      (pkgs.texlive.combined.scheme-minimal.withPackages (ps : [
        ps.latex
      ]))
    ];
    preBuild = builtins.concatStringsSep "\n" [
      "export HOME=\"$TMPDIR/home\""
      "mkdir -p \"$HOME\""
      "sed -i 's|./build-aux/gitlog-to-auctexlog && cat ChangeLog.1 >> $@|cat ChangeLog.1 >> $@|' GNUmakefile"
      (old.preBuild or "")
    ];
    buildInfo = builtins.concatStringsSep "\n" [
      "rm -rf .auctex-info"
      "mkdir -p .auctex-info"
      "for texi in doc/auctex.texi doc/preview-latex.texi; do"
      "  infoFile=\"$(basename \"$texi\" .texi).info\""
      "  echo \"building AUCTeX info: $texi -> $infoFile\""
      "  rm -rf \"$infoFile\" \".auctex-info/$infoFile\""
      "  makeinfo --no-split \"$texi\" -o \".auctex-info/$infoFile\""
      "  rm -rf \"$infoFile\""
      "done"
    ];
    installInfo = builtins.concatStringsSep "\n" [
      "mkdir -p $info/share"
      "install -d $info/share/info"
      "for i in .auctex-info/*.info; do"
      "  test -f \"$i\" || continue"
      "  install -t $info/share/info \"$i\""
      "done"
    ];
  };

}
