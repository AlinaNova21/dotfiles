{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.fonts;
in {
  options.acme.fonts.enable = lib.mkEnableOption "fonts.";
  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      (nerdfonts.override {fonts = ["FiraCode"];})
    ];
  };
}
