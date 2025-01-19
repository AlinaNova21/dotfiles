{
  config,
  lib,
  ...
}: let
  cfg = config.acme.roles;
in
  with lib; {
    options = {
      acme.roles.server = {
        enable = mkEnableOption "server";
      };
    };
    config = mkIf (cfg.server.enable) {
      acme.roles.minimal.enable = true;
    };
  }
