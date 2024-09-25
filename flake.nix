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
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
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
        ];
    in rec {
      nixosConfigurations = {
        ims-alina = import ./hosts/ims-alina { inherit inputs globals overlays; };
        laptop-wsl = import ./hosts/laptop-wsl { inherit inputs globals overlays; };
        pixelbook = import ./hosts/pixelbook { inherit inputs globals overlays; };
      };
      darwinConfigurations = {
        alinas-mbp = import ./hosts/alinas-mbp { inherit inputs globals overlays; };
      };
      homeConfigurations = { 
        ims-alina = nixosConfigurations.ims-alina.config.home-manager.users.${globals.user}.home;
        nix-dev = nixosConfigurations.nix-dev.config.home-manager.users.${globals.user}.home;
        laptop-wsl = nixosConfigurations.laptop-wsl.config.home-manager.users.${globals.user}.home;
        pixelbook = nixosConfigurations.pixelbook.config.home-manager.users.${globals.user}.home;
        alinas-mbp = darwinConfigurations.alinas-mbp.config.home-manager.users."alinashumann".home;
      };

      # Development environments
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in {
          # Used to run commands and edit files in this repo
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git nixfmt shfmt shellcheck nixos-rebuild home-manager];
          };

          # Used for cloud and systems development and administration
          devops = pkgs.mkShell { buildInputs = with pkgs; [ git ]; };

        });
    };
}
