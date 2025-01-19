{
  config,
  lib,
  sysConfig,
  pkgs,
  ...
}: {
  config = {
    networking.nameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4"];
    services.openssh.enable = true;
    users.users.root = {
      initialHashedPassword = lib.mkForce null;
      openssh.authorizedKeys.keys = sysConfig.acme.sshKeys;
    };
  };
}
