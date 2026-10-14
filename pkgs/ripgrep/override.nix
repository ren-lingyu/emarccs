{ pkgs, lib, llib } : {

  scope = {
    executablePackages = { final, prev } : with pkgs; [
      ripgrep
    ];
  };

}
