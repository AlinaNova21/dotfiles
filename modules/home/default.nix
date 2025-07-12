{inputs, ...}: {
  imports = [
    ./catppuccin.nix
    ./desktop
    ./dev.nix
    ./dotfiles.nix
    ./keybase.nix
    ./programming
    ./shell
  ];
  config = {
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
    home.stateVersion = "24.11";
  };
}
