{
  config,
  flake,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.rescue;
  wrapConfig = module: args: module (args // {inherit flake inputs pkgs;});
in {
  options = {
    acme.rescue2 = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable rescue system";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    specialisation = {
      rescue = {
        inheritParentConfig = false;
        configuration = wrapConfig (args: {
          imports = [
            flake.nixosConfigurations.installer
          ];
          config = {
            disabledModules = [
              "profiles/all-hardware.nix"
            ];
            facter.reportPath = config.facter.reportPath;
            fileSystems = config.fileSystems;
            networking.hostId = config.networking.hostId;
            nixpkgs.hostPlatform = config.nixpkgs.hostPlatform;
            system.installer.channel.enable = false;
            system.stateVersion = config.system.stateVersion;
          };
        });
      };
    };
  };
}
