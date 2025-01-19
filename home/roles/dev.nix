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

      acme.dotfiles.enable = true;
      acme.gh.enable = true;
      acme.gh.copilot = true;
      acme.kubernetes.enable = true;
    };
  }
