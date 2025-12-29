{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.acme.nushell;
in
  with lib; {
    options.acme.nushell = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nushell with integrations";
      };
    };

    config = mkIf cfg.enable {
      # Add nushell to the shells list for automatic tool integrations
      acme.shells.enabled = ["nushell"];

      programs.nushell = {
        enable = true;
        extraEnv = ''
          $env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local" "bin"))
          $env.GPG_TTY = (tty)
        '';
      };

      # Tool integrations now handled by shells.nix
    };
  }
