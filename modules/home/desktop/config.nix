{
  config,
  lib,
  ...
}:
{
  options.acme.desktop.configs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "hypr"
      "uwsm"
      "hyprpanel"
      "niri"
      "ashell"
      "noctalia"
    ];
  };

  config = lib.mkIf config.acme.desktop.enable {
    # DISABLED (Stage 2 of mise migration): desktop config dirs are now owned by mise
    # [dotfiles] (mirror-style, via dotfiles.root -> repo/.config/<name>). The nix
    # xdg.configFile out-of-store symlinks are no longer generated. acme.desktop.configs
    # option + utils.mapConfigDir remain defined (inert) for reference/rollback.
    # xdg.configFile = lib.mkMerge (
    #   map (name: config.acme.utils.mapConfigDir name)
    #       config.acme.desktop.configs
    # );
  };
}
