{
  config,
  lib,
  ...
}: let
  cfg = config.acme.bash;
in
  with lib; {
    options.acme.bash = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable bash shell with tool integrations";
      };
    };

    config = mkIf cfg.enable {
      # Add bash to the shells list for automatic tool integrations
      acme.shells.enabled = ["bash"];

      programs.bash = {
        enable = true;
        enableCompletion = true;
      };

      # Tool integrations now handled by shells.nix
    };
  }
