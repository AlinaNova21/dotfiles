{config, inputs, lib, pkgs, ...}: {
  options.sway.enable = lib.mkEnableOption "sway.";
  config = lib.mkIf config.sway.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    home-manager.users.${config.user} = {
      wayland.windowManager.sway = {
        enable = true;
        config = {
          modifier = "Mod4";
          terminal = "foot";
        };
      };
      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "FiraCode Nerd Font Mono:size=8";
            dpi-aware = "yes";
          };
          mouse = {
            hide-when-typing = "yes";
          };
        };
      };
    };
  };
}