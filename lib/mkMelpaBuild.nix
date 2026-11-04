melpaBuild: argsFn:
melpaBuild (
  finalAttrs:
  let
    args = if builtins.isFunction argsFn then argsFn finalAttrs else argsFn;
    packageName = args.ename or args.pname;

    caseInsensitive =
      name:
      let
        lower = "abcdefghijklmnopqrstuvwxyz";
        upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        chars = s: builtins.genList (i: builtins.substring i 1 s) (builtins.stringLength s);
        lowerChars = chars lower;
        upperChars = chars upper;
        patterns = builtins.genList (
          i: "[${builtins.elemAt lowerChars i}${builtins.elemAt upperChars i}]"
        ) (builtins.stringLength lower);
      in
      builtins.replaceStrings (lowerChars ++ upperChars) (patterns ++ patterns) name;

    libraryFile =
      args.libraryFile or (
        if builtins.pathExists "${finalAttrs.src}/${packageName}.el" then
          "${packageName}.el"
        else if builtins.pathExists "${finalAttrs.src}/lisp/${packageName}.el" then
          "lisp/${packageName}.el"
        else
          null
      );

    lines =
      if libraryFile == null then
        [ ]
      else
        builtins.filter builtins.isString (
          builtins.split "\n" (builtins.readFile "${finalAttrs.src}/${libraryFile}")
        );

    header =
      name:
      let
        found = builtins.filter (match_: match_ != null) (
          builtins.map (
            line:
            builtins.match (";;[[:space:]]*${caseInsensitive name}:[[:space:]]*([^[:space:]]+)[[:space:]]*") line
          ) lines
        );
      in
      if found == [ ] then null else builtins.head (builtins.head found);

    headerVersion =
      let
        packageVersion = header "Package-Version";
      in
      if packageVersion != null then packageVersion else header "Version";

    version =
      args.version or (
        if headerVersion != null then
          headerVersion
        else
          throw "Cannot determine Emacs package version for ${packageName}"
      );

    callerMeta = args.meta or { };
  in
  (builtins.removeAttrs args [ "libraryFile" ])
  // {
    inherit version;

    melpaVersion = args.melpaVersion or (builtins.replaceStrings [ "-pre" ] [ "pre" ] version);

    meta =
      callerMeta
      // (
        if callerMeta ? homepage then
          { }
        else
          {
            homepage =
              let
                url = header "URL";
              in
              if url == null then "" else url;
          }
      );
  }
)
