{
  config,
  lib,
  pkgs,
  sysConfig,
  ...
}: let
  cfg = config.acme.desktop;
in
  with lib; {
    imports = [
      ./hyprland.nix
      ./hyprpanel.nix
    ];
    options.acme.desktop = {
      enable = mkEnableOption "Enable Desktop Group";
    };
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        google-chrome
      ];
      acme = {
        hyprland.enable = true;
        hyprpanel.enable = true;
      };
    };
  }
