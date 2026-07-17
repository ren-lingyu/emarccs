{ pkgs, lib } : {

  input = final_ : super_ : {
    packageRequires = (super_.packageRequires or {}) // {
      math-symbol-lists = "0";
    };
  };

}
