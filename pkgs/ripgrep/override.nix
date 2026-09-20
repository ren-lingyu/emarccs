{ pkgs, lib } : {

  scope = {
    executablePackages = { final, prev } : with pkgs; [
      ripgrep
    ];
  };

}
