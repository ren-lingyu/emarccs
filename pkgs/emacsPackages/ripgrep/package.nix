{ ripgrep, rg }:

ripgrep.overrideAttrs (old_: {
  propagatedUserEnvPkgs = builtins.concatLists [
    (old_.propagatedUserEnvPkgs or [ ])
    [ rg ]
  ];
})
