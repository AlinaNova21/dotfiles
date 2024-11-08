{config, lib, pkgs, pkgs-unstable, ...}: {
  imports = [
    ./applications
    ./programming
    ./repositories
    ./shell
  ];
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "Primary user of the system";
    };
    homePath = lib.mkOption {
      type = lib.types.path;
      description = "Path of user's home directory.";
      default = builtins.toPath (if pkgs.stdenv.isDarwin then
        "/Users/${config.user}"
      else
        "/home/${config.user}");
    };  
    dotfilesPath = lib.mkOption {
      type = lib.types.path;
      description = "Path of dotfiles repository.";
      default = config.homePath + "/projects/dotfiles";
    };
    dotfilesRepo = lib.mkOption {
      type = lib.types.str;
      description = "Link to dotfiles repository.";
    };
    unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of unfree packages to allow.";
      default = [ ];
    };
  };
  config = let stateVersion = "24.05";
  in {

    nix = {

      # Enable features in Nix commands
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
      '';

      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

      settings = {

        # Add community Cachix to binary cache
        builders-use-substitutes = true;
        substituters = lib.mkIf (!pkgs.stdenv.isDarwin)
          [ "https://nix-community.cachix.org" ];
        trusted-public-keys = lib.mkIf (!pkgs.stdenv.isDarwin) [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # Scans and hard links identical files in the store
        # Not working with macOS: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = lib.mkIf (!pkgs.stdenv.isDarwin) true;

      };

    };

    # Basic common system packages for all devices
    environment.systemPackages = with pkgs; [ git nano vim wget curl ];

    # Use the system-level nixpkgs instead of Home Manager's
    home-manager.useGlobalPkgs = true;

    # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
    # using multiple profiles for one user
    # home-manager.useUserPackages = true;

    # Allow specified unfree packages (identified elsewhere)
    # Retrieves package object based on string name
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.unfreePackages;
    # Pin a state version to prevent warnings
    home-manager.users.${config.user} = {
      home = {
        stateVersion = stateVersion;
        homeDirectory = config.homePath;
        username = config.user;
      };
      programs.home-manager.enable = true;
    };
    
    home-manager.users.root.home.stateVersion = stateVersion;
    system.stateVersion = stateVersion;
  };
}