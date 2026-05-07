{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.server;
in
  with lib; {
    options.acme.server = {
      enable = mkEnableOption "server profile";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [age sops];

      # nvim requires dotfiles; keep them coupled
      acme.nvim.enable = mkDefault true;
      acme.dotfiles.enable = mkDefault true;
    };
  }
