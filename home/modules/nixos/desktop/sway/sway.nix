{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.sway.enable = lib.mkEnableOption "sway.";
  config = lib.mkIf config.sway.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    programs.waybar.enable = true;
    home-manager.users.${config.user} = {
      wayland.windowManager.sway = {
        enable = true;
        config = {
          modifier = "Mod4";
          terminal = "foot";
          bars = [
            {
              command = "${pkgs.waybar}/bin/waybar";
            }
          ];
        };
      };
      programs.foot.enable = true;
    };
  };
}
