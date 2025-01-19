{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    programs.zsh.enable = true;

    users.users = {
      root = {
        hashedPasswordFile = config.sops.secrets.hashedPassword.path;
        openssh.authorizedKeys.keys = config.acme.sshKeys;
        shell = pkgs.zsh;
      };
      alina = {
        hashedPasswordFile = config.sops.secrets.hashedPassword.path;
        isNormalUser = true;
        openssh.authorizedKeys.keys = config.acme.sshKeys;
        extraGroups = ["wheel" "networkmanager"];
        createHome = true;
        shell = pkgs.zsh;
      };
    };
  };
}
