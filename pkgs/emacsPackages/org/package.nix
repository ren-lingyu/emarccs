{
  src,
  csl-locales,
  lib,
  melpaBuild,
  compat,
  gnumake,
  emacs,
}:
melpaBuild (finalAttrs_: {
  src = src;

  pname = "org";

  commit = finalAttrs_.src.rev;

  files = "(:defaults \"etc\")";

  packageRequires = [ compat ];

  nativeBuildInputs = [ gnumake ];

  preBuild = builtins.concatStringsSep "\n" [
    "make autoloads ORGVERSION=${finalAttrs_.version} GITVERSION=${
      builtins.substring 0 8 finalAttrs_.commit
    } EMACS=${lib.getExe emacs}"
  ];

  postPatch = ''
    cp ${csl-locales}/locales-*.xml etc/csl/
    printf '%s\n' \
      'Additional CSL locales: https://citationstyles.org/ (CC BY-SA 3.0).' \
      >> etc/csl/README
  '';

  meta = {
    license = [
      lib.licenses.gpl3Plus
      lib.licenses.cc-by-sa-30
    ];
  };
})
