{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.gui.enable = lib.mkEnableOption "gui.";
  config = lib.mkIf config.gui.enable {
    sway.enable = true;
    greetd.enable = true;
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      (nerdfonts.override {fonts = ["FiraCode"];})
    ];
  };
}
