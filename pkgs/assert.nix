{ pkgs } : let

  boolToString_ = x_ : if x_ then "true" else "false";

  indent_ = level_ : builtins.concatStringsSep "" (
    builtins.genList (_ : "  ") level_
  );

  eval_ = packages_ : name_ : files_ : predicate_ : if predicate_ ? exists then let
    value_ = builtins.hasAttr predicate_.exists files_;
  in {
    value = value_;
    label = "exists \"${predicate_.exists}\"";
    children = [];
  }

  else if predicate_ ? inPackages then let
    value_ = builtins.elem name_ packages_;
  in {
    value = value_;
    label = "member in packages";
    children = [];
  }

  else if predicate_ ? all then let
    children_ = builtins.map
      (x_ : eval_ packages_ name_ files_ x_)
      predicate_.all;
  in {
    value = builtins.all (x_ : x_.value) children_;
    label = "all";
    children = children_;
  }

  else if predicate_ ? any then let
    children_ = builtins.map
      (x_ : eval_ packages_ name_ files_ x_)
      predicate_.any;
  in {
    value = builtins.any (x_ : x_.value) children_;
    label = "any";
    children = children_;
  }

  else if predicate_ ? not then let
    child_ = eval_ packages_ name_ files_ predicate_.not;
  in {
    value = !child_.value;
    label = "not";
    children = [ child_ ];
  }

  else if predicate_ ? implies then let
    left_ = eval_
      packages_
      name_
      files_
      (builtins.elemAt predicate_.implies 0);

    right_ = eval_
      packages_
      name_
      files_
      (builtins.elemAt predicate_.implies 1);
  in {
    value = !left_.value || right_.value;
    label = "implies";
    children = [ left_ right_ ];
  }

  else if predicate_ ? iff then let
    left_ = eval_
      packages_
      name_
      files_
      (builtins.elemAt predicate_.iff 0);

    right_ = eval_
      packages_
      name_
      files_
      (builtins.elemAt predicate_.iff 1);
  in {
    value = left_.value == right_.value;
    label = "iff";
    children = [ left_ right_ ];
  }

  else throw "emarccs: unknown package assertion predicate";

  renderPredicate_ = level_ : result_ :
  builtins.concatStringsSep "\n" (builtins.concatLists
    [
      [
        "${indent_ level_}${result_.label} => ${boolToString_ result_.value}"
      ]
      (builtins.map
        (child_ : renderPredicate_ (level_ + 1) child_)
        result_.children
      )
    ]
  );

  renderFailure_ = failure_ : let
    entries_ = (pkgs.lib.mapAttrsToList
      (name_ : type_ : "${name_} (${type_})")
      failure_.files
    );
  in builtins.concatStringsSep "\n" (builtins.concatLists
    [
      [
        "${failure_.name}:"
        "  member in packages: ${boolToString_ failure_.inPackages}"
        "  entries: ${if entries_ == [] then "<empty>" else builtins.concatStringsSep ", " entries_}"
      ]
      (builtins.concatLists (builtins.map
        (predicateFailure_ : [
          "  predicate ${toString (predicateFailure_.index + 1)}:"
          (renderPredicate_ 2 predicateFailure_.result)
        ])
        failure_.predicateFailures
      ))
    ]
  );

in { rootDir, packages, predicates } : let

  directories_ = (pkgs.lib.filterAttrs
    (_ : type_ : type_ == "directory")
    (builtins.readDir rootDir)
  );

  results_ = (pkgs.lib.mapAttrsToList
    (name_ : _ : let
      files_ = builtins.readDir (rootDir + "/${name_}");

      predicateResults_ = builtins.genList
        (index_ : {
          index = index_;
          result = eval_
            packages
            name_
            files_
            (builtins.elemAt predicates index_);
        })
        (builtins.length predicates);

      predicateFailures_ = (builtins.filter
        (x_ : !x_.result.value)
        predicateResults_
      );
    in {
      name = name_;
      files = files_;
      inPackages = builtins.elem name_ packages;
      predicateFailures = predicateFailures_;
    })
    directories_
  );

  failures_ = (builtins.filter
    (x_ : x_.predicateFailures != [])
    results_
  );

in (
  assert (pkgs.lib.assertMsg
    (failures_ == [])
    (builtins.concatStringsSep
      "\n"
      [
        "emarccs: invalid package directory structure"
        ""
        (builtins.concatStringsSep "\n\n" (
          builtins.map renderFailure_ failures_
        ))
      ]
    )
  );
  true
)
