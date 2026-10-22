final_: prev_: {

  treesit-auto = prev_.treesit-auto.overrideAttrs (old_: {

    propagatedUserEnvPkgs = builtins.concatLists [
      (old_.propagatedUserEnvPkgs or [ ])
      [ final_.treesit-grammars.with-all-grammars ]
    ];

    patches = builtins.concatLists [
      (old_.patches or [ ])
      [ ./load-name-overrides.patch ]
    ];

  });

}
