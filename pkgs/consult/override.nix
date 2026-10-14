{ pkgs, llib } : {

  scope = {
    executablePackages = { final, prev } : with pkgs; [
      gnugrep
      ripgrep
    ];
  };

}
