{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.dev;
in
  with lib; {
    options.acme.dev = {
      enable = mkEnableOption "dev";
    };
    config = mkIf (cfg.enable) {
      acme.direnv.enable = true;
      acme.dotfiles.enable = true;
      acme.gh.enable = true;
      # acme.gh.copilot = true;
      acme.helix.enable = true;
      acme.kubernetes.enable = true;

      home.packages = with pkgs; [
        age
        sops
      ];
    };
  }
