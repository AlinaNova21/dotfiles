{
  inputs,
  pkgs,
  ...
}: {
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

  nixpkgs.overlays = [inputs.hyprpanel.overlay];
}
