{ pkgs, lib } : {

  scope = {
    executablePackages = { final, prev } : with pkgs; [
      gnugrep
      ripgrep
    ];
  };

}
