{ pkgs, lib } : let

  removeReferences_ = (pkgs.lib.concatMapStringsSep
    (builtins.fromJSON "\"\\u0020\"")
    (x_ : "-t ${x_}")
    (
      builtins.concatLists [
        [
          pkgs.glib.dev
          pkgs.libpng.dev
          pkgs.poppler.dev
          pkgs.zlib.dev
          pkgs.cairo.dev
        ]
        (pkgs.lib.optional
          pkgs.stdenv.hostPlatform.isLinux
          pkgs.stdenv.cc.libc.dev
        )
      ]
    )
  );

in {

  scope = {

    overrideAttrs = { old, ... } : {

      env = (old.env or {}) // {
        CXXFLAGS = "-std=c++17";
      };

      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
        pkgs.autoconf
        pkgs.automake
        pkgs.pkg-config
        pkgs.removeReferencesTo
      ];

      buildInputs = (old.buildInputs or []) ++ [
        pkgs.libpng
        pkgs.zlib
        pkgs.poppler
      ];

      preBuild = builtins.concatStringsSep "\n" [
        (old.preBuild or "")
        "make -C build server/epdfinfo"
        "remove-references-to ${removeReferences_} build/server/epdfinfo"
        "ln -s build/server/epdfinfo epdfinfo"
      ];

    };

  };

}
