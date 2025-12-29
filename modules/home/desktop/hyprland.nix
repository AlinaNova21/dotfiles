{
  config,
  lib,
  pkgs,
  sysConfig,
  ...
}: let
  cfg = config.acme.hyprland;
in {
  options.acme.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  config = lib.mkIf cfg.enable {
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.kitty.enable = false;

    xdg.configFile."hypr" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.acme.dotfiles.path}/config/hypr";
    };

    xdg.configFile."uwsm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.acme.dotfiles.path}/config/uwsm";
    };
  };
}
