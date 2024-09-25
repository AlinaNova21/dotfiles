{ self, nixpkgs, nix-on-droid, ... }:
with inputs;
nix-on-droid.lib.nixOnDroidConfiguration {
  pkgs = import nixpkgs { system = "aarch64-linux"; };
  modules = [
    ../../modules/common
    {
      system.stateVersion = "24.05";
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
    }
  ];
}