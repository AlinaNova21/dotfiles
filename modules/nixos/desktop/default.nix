{
  config,
  lib,
  ...
}: let
  cfg = config.acme.desktop;
in
  with lib; {
    options.acme.desktop = {
      enable = mkOption {
        type = types.bool;
        default = sysConfig.acme.desktop.enable;
        description = "Enable Desktop Group";
      };
    };
    imports = [
      # ./ags.nix
      ./fonts.nix
      ./greetd.nix
      ./hyprland.nix
      # ./sway
    ];
    config = mkIf cfg.enable {
      acme = {
        fonts.enable = true;
        greetd.enable = true;
        hyprland.enable = true;
      };
    };
  }
