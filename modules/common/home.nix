{
  inputs,
  config,
  lib,
  outputs,
  pkgs,
  ...
}: {
  config = {
    home-manager = {
      # Use the system-level nixpkgs instead of Home Manager's
      useGlobalPkgs = true;

      # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
      # using multiple profiles for one user
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs outputs;
        sysConfig = config;
      };
    };
  };
}
