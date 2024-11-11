{config, inputs, lib, pkgs, ... }: lib.mkIf config.programs.waybar.enable {
  home-manager.users.${config.user} = {
    wayland.windowManager.sway.config.bars = [{
      command = "${pkgs.waybar}/bin/waybar";
    }];
  };
}