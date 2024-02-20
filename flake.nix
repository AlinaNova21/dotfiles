{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs: let
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
    arch = "x86_64-linux"; # or aarch64-darwin
    hosts = {
      ims-alina = {
        username = "alina";
        system = "x86_64-linux";
      };
      alinas-mbp = {
        username = "alinashumann";
        system = "aarch64-darwin";
      };
    };
  in {
    nixosConfigurations = {
      ims-alina = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = globalModulesNixos ++ [
          ./hosts/ims-alina/configuration.nix
        ];
      };
      nixos-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = globalModulesNixos ++ [
          ./hosts/nixos-test/configuration.nix
        ];
      };
    };
    darwinConfigurations = {};
    homeConfigurations = {
      "alina@ims-alina" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${hosts.ims-alina.system};
        modules = [
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
      "alinashumann" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${hosts.alinas-mbp.system};
        modules = [
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
    };
  };
}

#references
# https://github.com/diego-vicente/dotfiles/