{
  src,
  lib,
  melpaBuild,
  org,
}:
melpaBuild {
  inherit src;

  pname = "org-include-inline";
  version = "0.1.0";
  melpaVersion = "0.1.0";

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
