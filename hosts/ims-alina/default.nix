{
  home-manager.users.alina = import ../../home "standalone" "alina" {};
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";
}
