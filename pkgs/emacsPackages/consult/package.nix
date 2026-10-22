{
  consult,
  rg,
  gnugrep,
}:
consult.overrideAttrs (old_: {
  propagatedUserEnvPkgs = builtins.concatLists [
    (old_.propagatedUserEnvPkgs or [ ])
    [
      rg
      gnugrep
    ]
  ];
})
