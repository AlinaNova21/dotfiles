{ inputs, globals, overlays, ... }:
with inputs;
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    globals
    home-manager.nixosModules.home-manager
    # ./modules/tailscale.nix
    ../../modules/common
    ../../modules/nixos
    {
      kubernetes.enable = true;
    }
  ];
  # home-manager.users.${globals.user}.home = ../../home.personal.nix;
}