{
  config,
  lib,
  ...
}: {
  options.acme.desktop.configs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = ["hypr" "uwsm" "hyprpanel" "niri" "ashell"];
  };

  config = lib.mkIf config.acme.desktop.enable {
    xdg.configFile = lib.mkMerge (
      map (name: config.acme.utils.mapConfigDir name)
          config.acme.desktop.configs
    );
  };
}