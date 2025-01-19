{
  config,
  lib,
  ...
}: let
  cfg = config.acme.roles;
in
  with lib; {
    options = {
      acme.roles.dev = {
        enable = mkEnableOption "dev";
      };
    };
    config = mkIf (cfg.dev.enable) {
      acme.roles.minimal.enable = true;
    };
  }
