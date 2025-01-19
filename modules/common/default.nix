{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./home.nix
    ./nix.nix
    ./sops.nix
  ];
  options = {
    acme = {
      gitName = mkOption {
        type = types.str;
        description = "Your git name";
      };
      gitEmail = mkOption {
        type = types.str;
        description = "Your git email";
      };
      dotfilesRepo = mkOption {
        type = types.str;
      };
      sshKeys = lib.mkOption {
        type = with lib.types; listOf string;
        default = [];
        example = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDq"];
      };
    };
  };
}
