system: username: module: {
  config,
  lib,
  pkgs,
  sysConfig,
  ...
}: let
  stateVersion = "24.11";
in {
  imports = [
    ./roles
    ./modules/common
    ./modules/${system}
    module
  ];
  options = {
    acme = {
      user = lib.mkOption {
        type = lib.types.str;
        description = "Primary user of the system";
        default = username;
      };
      homePath = lib.mkOption {
        type = lib.types.path;
        description = "Path of user's home directory.";
        default = builtins.toPath (
          if pkgs.stdenv.isDarwin
          then "/Users/${config.acme.user}"
          else if config.acme.user == "root"
          then "/root"
          else "/home/${config.acme.user}"
        );
      };
      dotfilesPath = lib.mkOption {
        type = lib.types.path;
        description = "Path of dotfiles repository.";
        default = config.acme.homePath + "/.config/home-manager";
      };
      dotfilesRepo = lib.mkOption {
        type = lib.types.str;
        description = "Link to dotfiles repository.";
        default = sysConfig.acme.dotfilesRepo;
      };
      unfreePackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of unfree packages to allow.";
        default = [];
      };
      isRoot = lib.mkOption {
        type = lib.types.bool;
        description = "Is this the root user?";
        default = config.acme.user == "root";
      };
    };
  };
  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = _: true;
    # TODO: setup predicate to allow unfree packages
    home = {
      stateVersion = stateVersion;
      homeDirectory = config.acme.homePath;
      username = config.acme.user;
    };
    programs.home-manager.enable = true;
  };
}
