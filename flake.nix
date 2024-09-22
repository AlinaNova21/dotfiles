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
    nixos-wsl.url = "github:nix-community/nixos-wsl";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, nixos-wsl, ... }@inputs:
    let
      globals = rec {
        user = "alina";
        gitName = "Alina Shumann";
        gitEmail = "alina@alinanova.dev";
        dotfilesRepo = "git@github.com:AlinaNova21/dotfiles";
      };
      overlays = [ ];
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
          globalModules = [{
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
          # ./modules/global/global.nix 
        ];
      # globalModulesNixos = globalModules
      #   ++ [ ./modules/global/nixos.nix home-manager.nixosModules.default ];
      # globalModulesMacos = globalModules
      #   ++ [ ./modules/global/macos.nix home-manager.darwinModules.default ];
      hosts = {
        ims-alina = {
          username = "alina";
          system = "x86_64-linux";
          modules = [ ./modules/tailscale.nix ];
          homeModules = [
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
          modules = [ ./modules/tailscale.nix ];
          homeModules = [ ./home.nix ];
        };
        alinas-mbp = {
          username = "alinashumann";
          system = "aarch64-darwin";
          modules = [ ];
          homeModules = [
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
          modules = [ nixos-wsl.nixosModules.wsl ];
          homeModules = [ ./home.nix ];
        };
      };
    in rec {
      # nixosConfigurations = nixpkgs.lib.mapAttrs (name: value:
      #   nixpkgs.lib.nixosSystem {
      #     system = hosts.${name}.system;
      #     modules = globalModulesNixos ++ hosts.${name}.modules
      #       ++ [ ./hosts/${name}/configuration.nix ];
      #     specialArgs = {
      #       pkgs-unstable = import nixpkgs-unstable {
      #         system = hosts.${name}.system;
      #         config.allowUnfree = true;
      #       };
      #     };
      #   }) hosts;
      nixosConfigurations = {
        ims-alina = import ./hosts/ims-alina { inherit inputs globals overlays; };
      };
      darwinConfigurations = {
        alinas-mbp = import ./hosts/alinas-mbp { inherit inputs globals overlays; };
      };
      homeConfigurations = { 
        ims-alina = nixosConfigurations.ims-alina.config.home-manager.users.${globals.user}.home;
        nix-dev = nixosConfigurations.nix-dev.config.home-manager.users.${globals.user}.home;
        alinas-mbp = darwinConfigurations.alinas-mbp.config.home-manager.users."Alina.Shumann".home;
      };
      # homeConfigurations = nixpkgs.lib.mapAttrs' (name: value:
      #   nixpkgs.lib.nameValuePair ("${value.username}@${name}")
      #   (home-manager.lib.homeManagerConfiguration {
      #     pkgs = nixpkgs.legacyPackages.${value.system};
      #     modules = value.homeModules;
      #   })) hosts;

      # Development environments
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in {
          # Used to run commands and edit files in this repo
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git nixfmt shfmt shellcheck ];
          };

          # Used for cloud and systems development and administration
          devops = pkgs.mkShell { buildInputs = with pkgs; [ git ]; };

        });
    };
}

#references
# https://github.com/diego-vicente/dotfiles/
