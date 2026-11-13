{ extraArgs }: final_: prev_: {
  treesit-auto = prev_.treesit-auto.overrideAttrs (
    finalAttrs_: old_: {
      propagatedUserEnvPkgs = builtins.concatLists [
        (old_.propagatedUserEnvPkgs or [ ])
        [ final_.treesit-grammars.with-all-grammars ]
      ];

      patches = builtins.concatLists [
        (old_.patches or [ ])
        [ ./load-name-overrides.patch ]
      ];

      passthru = extraArgs.lib.mergeAttrsList [
        (old_.passthru or { })
        {
          tests = extraArgs.lib.mergeAttrsList [
            (old_.passthru.tests or { })
            {
              grammars-runtime = final_.callPackage ./tests {
                inherit (extraArgs) withProgress;
                emacsPackage = final_.withPackages (_: [ finalAttrs_.finalPackage ]);
                grammarPackage = final_.treesit-grammars.with-all-grammars;
              };
            }
          ];
        }
      ];
    }
  );
}
