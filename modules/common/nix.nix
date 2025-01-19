{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  options = {
    acme = {
      unfreePackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of unfree packages to allow.";
        default = [];
      };
    };
  };
  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) config.acme.unfreePackages;
    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

      settings = {
        # Add community Cachix to binary cache
        builders-use-substitutes = true;
        substituters =
          lib.mkIf (!pkgs.stdenv.isDarwin)
          ["https://nix-community.cachix.org"];
        trusted-public-keys = lib.mkIf (!pkgs.stdenv.isDarwin) [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # Scans and hard links identical files in the store
        # Not working with macOS: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = lib.mkIf (!pkgs.stdenv.isDarwin) true;

        experimental-features = "nix-command flakes";
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };
  };
}
