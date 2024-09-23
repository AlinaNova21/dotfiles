{ inputs, globals, overlays, ... }:
with inputs;
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    globals
    home-manager.nixosModules.home-manager
    nixos-wsl.nixosModules.wsl
    # ./modules/tailscale.nix
    ../../modules/common
    ../../modules/nixos
    {
      wsl.enable = true;
      wsl.defaultUser = "alina";
      kubernetes.enable = true;
      tailscale.enable = true;
    }
  ];
  # home-manager.users.${globals.user}.home = ../../home.personal.nix;
}
