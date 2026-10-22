{ treesit-auto, treesit-grammars }:
treesit-auto.overrideAttrs (old_: {

  propagatedUserEnvPkgs = builtins.concatLists [
    (old_.propagatedUserEnvPkgs or [ ])
    [ treesit-grammars.with-all-grammars ]
  ];

  patches = builtins.concatLists [
    (old_.patches or [ ])
    [ ./load-name-overrides.patch ]
  ];

})
