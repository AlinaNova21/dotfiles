{
  config,
  lib,
  pkgs,
  sysConfig,
  ...
}:
let
  cfg = config.acme.desktop;
in
with lib;
{
  imports = [
    ./config.nix
    ./services.nix
    ./theming.nix
  ];
  options.acme.desktop = {
    enable = mkEnableOption "Enable Desktop Group";
  };
  config = mkIf cfg.enable {
    # chrome dropped (user call): no longer nix-installed (desktop package layer shrinking).
    # home.packages = with pkgs; [ google-chrome ];
    # Force Electron apps to use Wayland
    # DISABLED (mise migration): electron-flags.conf is now a mise dotfile
    # (repo .config/electron-flags.conf). home.file no longer generates it.
    # home.file.".config/electron-flags.conf".text = ''
    #   --enable-features=UseOzonePlatform
    #   --ozone-platform=wayland
    # '';

    # Force Chromium/Electron to use Wayland on NixOS
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

  };
}
