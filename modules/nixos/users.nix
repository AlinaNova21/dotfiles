{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  hashedPasswordFile = config.sops.secrets.hashedPassword.path;
  sshKeys = flake.acme.sshKeys;
in {
  config = {
    programs.zsh.enable = true;

    users.users = {
      root = {
        inherit hashedPasswordFile;
        openssh.authorizedKeys.keys = sshKeys;
        shell = pkgs.zsh;
      };
      alina = {
        inherit hashedPasswordFile;
        isNormalUser = true;
        openssh.authorizedKeys.keys = sshKeys;
        extraGroups = ["wheel" "networkmanager"];
        createHome = true;
        shell = pkgs.zsh;
      };
    };
  };
}
