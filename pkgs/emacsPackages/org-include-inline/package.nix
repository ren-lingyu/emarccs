{
  src,
  lib,
  melpaBuild,
  org,
}:
melpaBuild {
  inherit src;

  pname = "org-include-inline";

  files = "(:defaults)";

  patches = [ ./fix-byte-compile-warnings.patch ];

  packageRequires = [ org ];

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/yibie/org-include-inline";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
}
