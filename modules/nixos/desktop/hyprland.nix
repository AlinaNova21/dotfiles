{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.hyprland;
in {
  options.acme.hyprland.enable = lib.mkEnableOption "hyprland.";
  imports = [];
  config = lib.mkIf cfg.enable {
    acme.fonts.enable = true;
    environment.systemPackages = [
      pkgs.kitty # required for the default Hyprland config
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
}
