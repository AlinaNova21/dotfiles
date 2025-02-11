{
  description = "Your new nix config";

  inputs = {
    alejandra.url = "github:kamadorueda/alejandra/3.1.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
    blueprint.url = "github:numtide/blueprint";
    catppuccin.url = "github:catppuccin/nix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprpanel.url = "github:jas-singhfsu/hyprpanel/e19518ad60599569e4859ecf3d3eaa83b772268e";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.url = "github:nix-community/nix-on-droid/release-24.05";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-images.url = "github:nix-community/nixos-images";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: swap back to upstream when PR is merged: https://github.com/space-wizards/SS14.Watchdog/pull/35
    ss14-watchdog.url = "github:AlinaNova21/SS14.Watchdog/debug-nix";
    # ss14-watchdog.url = "github:space-wizards/SS14.Watchdog";
    ss14-watchdog.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    staticModule = {
      acme = {
        gitName = "Alina Shumann";
        gitEmail = "alina@alinanova.dev";
        dotfilesRepo = "git@github.com:AlinaNova21/dotfiles";
        sshKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlPf3egS4avuZs9+BCqO7mW1/uk1UOIBLX5oj9qtO3IHbHAJCXCAKcRmZPc6uGQpv2HZjcpkSnr1pxGT3mubcc8/tFR6JO3ZeTMfA6UcrOQjPJXv+/5w8sopdPjFETnnsaXxBKkjKh7aswiYzYoiXTYkUTuSIvh50uAs2HI+C18xYkKSMLOF+G6CQTMRFD+ZaqAZW1M0/L4gWvA/A2r6kzJzXrTLQTqaJ62KfuRbVL5YqYziO/cuXxbvnq2qP6bfk/6i+K7VnC7DZNu17XIYjU4ajy5YWBns7GksE5MopMUyOhLFuGRYGgNtqf1q621fcz+7b13OfM4hLCCU/N7oVB"
        ];
      };
    };
  in (inputs.blueprint {
      inherit inputs;
    }
    // {
      inherit (staticModule) acme;
      colmena = import ./hive.nix {inherit inputs outputs;};
      nixOnDroidConfigurations = {
        droid = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
          modules = [
            ./modules/common
            ./modules/nixOnDroid
          ];
          extraSpecialArgs = {
            inherit inputs outputs;
            flake = self;
          };
          pkgs = import nixpkgs {
            overlays = [inputs.nix-on-droid.overlays.default];
            system = "aarch64-linux";
          };
        };
      };
    });
}
