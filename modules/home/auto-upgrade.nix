{
  config,
  lib,
  ...
}: let
  cfg = config.acme.autoUpgrade;
in {
  options.acme.autoUpgrade = {
    enable = lib.mkEnableOption "Auto-upgrade home-manager via flake";
    frequency = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "How often to run home-manager auto-upgrade";
    };
  };

  config = lib.mkIf cfg.enable {
    services.home-manager.autoUpgrade = {
      enable = true;
      useFlake = true;
      flakeDir = config.acme.dotfiles.path;
      frequency = cfg.frequency;
      preSwitchCommands = ["git pull" "nix flake update"];
    };
  };
}