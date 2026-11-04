{
  src,
  lib,
  melpaBuild,
  org,
}:
melpaBuild {
  inherit src;

  pname = "org-workbench";
  version = "0.3.0";
  melpaVersion = "0.3.0";

  files = "(:defaults)";

  packageRequires = [ org ];

  patches = [ ./fix-byte-compile-warnings.patch ];

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/yibie/org-workbench";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
}
