{ pkgs, llib } : {

  scope = {
    executablePackages = { ... } : with pkgs; [
      coreutils
    ];
  };

}
