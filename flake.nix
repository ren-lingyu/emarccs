{
  description = "aRenCoco's Emacs configuration";
  outputs = { self } : {
    homeManagerModules.default = { config, lib, pkgs, ... }: {
      home.file = {
        ".emacs.d/init.el".source = "${self}/init.el";
        ".emacs.d/early-init.el".source = "${self}/early-init.el";
        ".emacs.d/lisp" = {
          source = "${self}/lisp";
          recursive = true;
        };
      };
    };
  };
}
