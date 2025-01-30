{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.hyprpanel;
in
  with lib; {
    imports = [
      inputs.hyprpanel.homeManagerModules.hyprpanel
    ];
    options.acme.hyprpanel = {
      enable = mkEnableOption "Hyprpanel";
    };
    config = mkIf cfg.enable {
      # nixpkgs.overlays = null;
      home.packages = with pkgs; [hyprpanel];
      programs.hyprpanel = {
        enable = true;
        hyprland.enable = true;
        theme = "catppuccin_mocha";
      };
    };
  }
