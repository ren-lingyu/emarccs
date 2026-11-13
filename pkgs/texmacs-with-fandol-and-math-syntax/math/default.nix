{ lib }:
let
  registry = import ./registry.nix;

  mkCodes =
    direction: count: kind: delimiter:
    [
      {
        name = "${direction}${count}${kind}";
        value = delimiter;
      }
    ]
    ++ lib.optional (count == "1") {
      name = "${direction}${kind}";
      value = delimiter;
    };

  codes =
    lib.concatLists (
      lib.mapAttrsToList (
        kind: layers:
        lib.concatLists (
          lib.mapAttrsToList (
            count: pair:
            mkCodes "l" count kind (builtins.elemAt pair 0) ++ mkCodes "r" count kind (builtins.elemAt pair 1)
          ) layers
        )
      ) registry
    )
    ++ [
      {
        name = "n";
        value = "<nobracket>";
      }
    ];

  pairs = lib.concatMap (
    left:
    map (right: {
      name = "${left.name}${right.name}";
      left = left.value;
      right = right.value;
    }) (builtins.filter (right: left.name != "n" || right.name != "n") codes)
  ) codes;

  # Only escape string leaves; the surrounding native tags are source syntax.
  escape = builtins.replaceStrings [ "\\" "<" ">" "|" ] [ "\\\\" "\\<" "\\>" "\\|" ];

  mkUnary =
    pair:
    "<assign|${pair.name}|<macro|body|<around*|${escape pair.left}|<arg|body>|${escape pair.right}>>>";

  mkVariadic =
    pair: "<assign|concat-${pair.name}|<xmacro|args|<${pair.name}|<map-args|identity|concat|args>>>>";

  delimiterDefinitions = lib.concatMap (pair: [
    (mkUnary pair)
    (mkVariadic pair)
  ]) pairs;

  mathDefinitions = [
    ''<assign|application|<macro|function|argument|<arg|function>\ <arg|argument>>>''
  ];

  uniqueNames =
    entries:
    builtins.length (
      builtins.attrNames (
        builtins.listToAttrs (
          map (entry: {
            inherit (entry) name;
            value = null;
          }) entries
        )
      )
    ) == builtins.length entries;
in
assert builtins.length codes == 47;
assert uniqueNames codes;
assert builtins.length pairs == 2208;
assert uniqueNames pairs;
assert builtins.length delimiterDefinitions == 4416;
''
  <TeXmacs|2.1.5>

  <style|<tuple|source|std>>

  <\body>
    ${lib.concatStringsSep "\n\n  " (delimiterDefinitions ++ mathDefinitions)}
  </body>

  <\initial>
    <\collection>
      <associate|preamble|true>
    </collection>
  </initial>
''
