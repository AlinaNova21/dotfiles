{
  imports = [
    ./desktop
    ./dev.nix
    ./dotfiles.nix
    ./keybase.nix
    ./programming
    ./shell
  ];
  config = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.11";
  };
}
