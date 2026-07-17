{ pkgs } : {
  
  concatMapEmacsTwists = f_ : emacsTwists_ : (pkgs.lib.concatMapAttrs (emacsName_ : variants_ : (
    pkgs.lib.concatMapAttrs (variantName_ : cfg_ : let
      name_ = "${emacsName_}-${variantName_}-twist";
    in (f_ name_ cfg_)) variants_)
  ) emacsTwists_);

  findUniqueLineNumber = file_ : line_ : let
    sourceLines_ = pkgs.lib.splitString "\n" (builtins.readFile file_);
    matchingLineNumbers_ = let
      go_ = lineNumber_ : lines_ : (
        if lines_ == [] then []
        else (
          (if builtins.head lines_ == line_ then [ lineNumber_ ] else [])
          ++ (go_ (lineNumber_ + 1) (builtins.tail lines_))
        )
      );
    in (go_ 1 sourceLines_);
  in (
    if builtins.length matchingLineNumbers_ == 1 then builtins.head matchingLineNumbers_
    else throw "Expected exactly one `${line_}` line in ${builtins.toString file_}"
  );
  
}
