{inputs, ...}: {
  imports = [
    ./catppuccin.nix
    ./xdg.nix
    ./utils.nix
    ./desktop
    ./dev.nix
    ./dotfiles.nix
    ./auto-upgrade.nix
    ./keybase.nix
    ./services.nix
    ./programming
    ./shell
    ./testing.nix
  ];
  config = {
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
    home.stateVersion = "26.05";
  };
}
