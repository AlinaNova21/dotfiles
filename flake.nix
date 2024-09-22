{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, home-manager, ... }@inputs: let
    globalModules = [ 
      { 
        system.configurationRevision = self.rev or self.dirtyRev or null; 
      }
      # ./modules/global/global.nix 
    ];
    globalModulesNixos = globalModules ++ [ 
      ./modules/global/nixos.nix
      home-manager.nixosModules.default
    ];
    globalModulesMacos = globalModules ++ [ 
      ./modules/global/macos.nix
      home-manager.darwinModules.default
    ];
    hosts = {
      ims-alina = {
        username = "alina";
        system = "x86_64-linux";
        modules = [
          ./modules/tailscale.nix
        ];
        homeModules = [
          ./home.nix
          ./home.personal.nix
          {
            home = {
              username = "alina";
              homeDirectory = "/home/alina";
            };
          }
        ];
      };
      nix-dev = {
        username = "alina";
        system = "x86_64-linux";
        modules = [
          ./modules/tailscale.nix
        ];
        homeModules = [
          ./home.nix
        ];
      };
      alinas-mbp = {
        username = "alinashumann";
        system = "aarch64-darwin";
        modules = [];
        homeModules =   [
          ./home.nix
          ./home.work.nix
          {
            home = {
              username = "alinashumann";
              homeDirectory = "/Users/alinashumann";
            };
          }
        ];
      };
      laptop-wsl = {
        username = "alina";
        system = "x86_64-linux";
        modules = [];
        homeModules = [
          ./home.nix
        ];
      };
    };
  in {
    nixosConfigurations = nixpkgs.lib.mapAttrs (name: value: nixpkgs.lib.nixosSystem {
      system = hosts.${name}.system;
      modules = globalModulesNixos ++ hosts.${name}.modules ++ [
        ./hosts/${name}/configuration.nix
      ];
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = hosts.${name}.system;
          config.allowUnfree = true;
        };
      };
    }) hosts;
    darwinConfigurations = {};
    homeConfigurations = nixpkgs.lib.mapAttrs' (name: value: nixpkgs.lib.nameValuePair ("${value.username}@${name}") (home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${value.system};
      modules = value.homeModules;
    })) hosts;
  };
}

#references
# https://github.com/diego-vicente/dotfiles/