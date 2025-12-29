{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.fish;
in
  with lib; {
    options.acme.fish = {
      enable = mkEnableOption "fish";
    };
    config = mkIf (cfg.enable) {
      # Add fish to the shells list for automatic tool integrations
      acme.shells.enabled = ["fish"];

      programs.fish = {
        enable = true;
        shellInit = ''
          fish_add_path --prepend ~/.local/bin
          set -gx GPG_TTY (tty)
        '';
      };

      # Tool integrations now handled by shells.nix
    };
  }
