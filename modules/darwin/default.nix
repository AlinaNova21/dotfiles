{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.sops-nix.darwinModules.sops
  ];
  options = {
    acme.user = lib.mkOption {
      default = "acme";
      type = lib.types.str;
    };
  };
  config = {
    users.users."${config.acme.user}" = {
      # macOS user
      home = "/Users/${config.acme.user}";
    };

    # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
    home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
    nixpkgs.hostPlatform = "aarch64-darwin";
  };
}
