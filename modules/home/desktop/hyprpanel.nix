{
  config,
  lib,
  ...
}: let
  cfg = config.acme.hyprpanel;
in
  with lib; {
    options.acme.hyprpanel = {
      enable = mkEnableOption "Hyprpanel";
    };
    config = mkIf cfg.enable {
      xdg.configFile."hyprpanel" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.acme.dotfiles.path}/config/hyprpanel";
      };
    };
  }
