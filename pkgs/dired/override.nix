{ pkgs, lib } : {

  scope = {
    executablePackages = { ... } : with pkgs; [
      coreutils
    ];
  };

}
