{
  flake,
  lib,
  ...
}: {
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme.desktop.enable = true;
  acme.dev.enable = true;
  acme.testing.enable = true;

  # Disable Hyprland and Hyprpanel nix management on this host
  acme.hyprland.enable = lib.mkForce false;
  acme.hyprpanel.enable = lib.mkForce false;

  programs.zsh.initContent = ''
    eval "$(fnm env --use-on-cd --shell zsh)"
  '';
  programs.git.signing = {
      signByDefault = true;
      key = "07D6E31CCAE33514";
    };
}

