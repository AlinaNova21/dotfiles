{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.testing;
in
  with lib; {
    options.acme.testing = {
      enable = mkEnableOption "testing";
    };
    config = mkIf (cfg.enable) {
      acme.dev.enable = true;
      acme.fish.enable = true;

      home.packages = with pkgs; [
        jujutsu
      ];
    };
  }
