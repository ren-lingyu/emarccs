{
  src,
  lib,
  melpaBuild,
  org,
}:
melpaBuild {
  inherit src;

  pname = "org-workbench";

  files = "(:defaults)";

  packageRequires = [ org ];

  patches = [ ./fix-byte-compile-warnings.patch ];

  turnCompilationWarningToError = true;

  meta = {
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
}
