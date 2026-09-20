{ pkgs, lib } : {

  scope = {
    executablePackages = { final, prev } : with pkgs; [
      (texmacs.override {
        extraFonts = true;
        chineseFonts = true;
        japaneseFonts = true;
        koreanFonts = true;
      })
    ];
  };

}
