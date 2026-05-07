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
      ./config.nix
      ./theming.nix
    ];
    options.acme.desktop = {
      enable = mkEnableOption "Enable Desktop Group";
    };
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        google-chrome
      ];
      # Force Electron apps to use Wayland
      home.file.".config/electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';

      # Force Chromium/Electron to use Wayland on NixOS
      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
    };
  }
