{
  config,
  lib,
  ...
}: let
  cfg = config.acme.roles;
in
  with lib; {
    options = {
      acme.roles.minimal = {
        enable = mkEnableOption "minimal";
      };
    };
    config =
      mkIf (cfg.minimal.enable) {
      };
  }
