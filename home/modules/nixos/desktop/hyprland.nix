{
  config,
  lib,
  pkgs,
  sysConfig,
  ...
}: let
  cfg = config.acme.hyprland;
in {
  options.acme.hyprland.enable = lib.mkOption {
    type = lib.types.bool;
    default = sysConfig.acme.hyprland.enable;
    description = "Enable Hyprland";
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.kitty.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      settings = {
        "$mod" = "SUPER";
        bind =
          [
            "$mod, Return, exec, ${pkgs.kitty}/bin/kitty"
            "$mod, m, close"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
      };
    };
  };
}
