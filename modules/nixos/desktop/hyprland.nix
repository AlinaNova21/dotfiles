{config, inputs, lib, pkgs, ...}: {
  
  options.hyprland.enable = lib.mkEnableOption "hyprland.";
  config = lib.mkIf config.hyprland.enable {
    home-manager.users.${config.user} = {
      wayland.windowManager.hyprland = {
        enable = true;
        # set the flake package
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      };
    };
  };
}