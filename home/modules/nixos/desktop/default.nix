{
  config,
  lib,
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
      enable = mkEnableOption "Desktop Group";
    };
    config = mkIf cfg.enable {
      acme = {
        hyprland.enable = true;
        hyprpanel.enable = true;
      };
    };
  }
