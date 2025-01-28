{
  description = "Your new nix config";

  inputs = {
    alejandra.url = "github:kamadorueda/alejandra/3.1.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
    ss14-watchdog.url = "github:AlinaNova21/SS14.Watchdog/update-nix";
    # ss14-watchdog.url = "github:space-wizards/SS14.Watchdog";
  };

  outputs = {
    self,
    alejandra,
    disko,
    flake-utils,
    home-manager,
    impermanence,
    nixos-anywhere,
    nixos-facter-modules,
    nixos-images,
    nixpkgs,
    sops-nix,
    ss14-watchdog,
    ...
  } @ inputs:
    with inputs; let
      inherit (self) outputs;
      utils = import ./utils.nix {inherit inputs outputs;};
      staticModule = {
        acme = {
          gitName = nixpkgs.lib.mkDefault "Alina Shumann";
          gitEmail = nixpkgs.lib.mkDefault "alina@alinanova.dev";
          dotfilesRepo = nixpkgs.lib.mkDefault "git@github.com:AlinaNova21/dotfiles";
          sshKeys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlPf3egS4avuZs9+BCqO7mW1/uk1UOIBLX5oj9qtO3IHbHAJCXCAKcRmZPc6uGQpv2HZjcpkSnr1pxGT3mubcc8/tFR6JO3ZeTMfA6UcrOQjPJXv+/5w8sopdPjFETnnsaXxBKkjKh7aswiYzYoiXTYkUTuSIvh50uAs2HI+C18xYkKSMLOF+G6CQTMRFD+ZaqAZW1M0/L4gWvA/A2r6kzJzXrTLQTqaJ62KfuRbVL5YqYziO/cuXxbvnq2qP6bfk/6i+K7VnC7DZNu17XIYjU4ajy5YWBns7GksE5MopMUyOhLFuGRYGgNtqf1q621fcz+7b13OfM4hLCCU/N7oVB"
          ];
        };
      };
      systems = {
        nixos = ["ims-alina" "lab" "liminality-srv1" "nixos-testing"];
        darwin = ["work-mbp"];
        nixOnDroid = [];
        # nixOnDroid = ["droid"];
      };
      nixosSystems = nixpkgs.lib.genAttrs systems.nixos (mapSystem "nixos");
      darwinSystems = nixpkgs.lib.genAttrs systems.darwin (mapSystem "darwin");
      nixOnDroidSystems =
        nixpkgs.lib.genAttrs systems.nixOnDroid (mapSystem "nixOnDroid");
      mapSystem = system: host: {
        specialArgs = {inherit inputs outputs;};
        modules = [
          staticModule
          ./hosts/${host}
          ./modules/common
          ./modules/${system}
          ./roles
        ];
      };
    in {
      inherit nixosSystems darwinSystems nixOnDroidSystems;
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = nixpkgs.lib.mapAttrs (_: system:
        nixpkgs.lib.nixosSystem {inherit (system) specialArgs modules;})
      nixosSystems;
      darwinConfigurations = nixpkgs.lib.mapAttrs (_: system:
        nix-darwin.lib.darwinSystem {inherit (system) specialArgs modules;})
      darwinSystems;
      nixOnDroidConfigurations = nixpkgs.lib.mapAttrs (_: system:
        nix-on-droid.lib.nixOnDroidConfiguration {
          inherit (system) modules;
          extraSpecialArgs = system.specialArgs;
          pkgs = import nixpkgs {
            overlays = [nix-on-droid.overlays.default];
            system = "aarch64-linux";
          };
        })
      nixOnDroidSystems;

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations =
        utils.homesFromConfigurations outputs.nixosConfigurations
        // utils.homesFromConfigurations outputs.darwinConfigurations
        // utils.homesFromConfigurations outputs.nixOnDroidConfigurations;

      utils = utils;
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            overlays = [];
            system = "x86_64-linux";
          };
          specialArgs = {inherit inputs outputs;};
        };
        lab = {
          deployment = {
            targetHost = "192.168.2.87";
            targetUser = "root";
          };
          imports = nixosSystems.lab.modules;
        };
        nixos-testing = {
          deployment = {
            targetHost = "192.168.2.114";
            targetUser = "root";
          };
          imports = nixosSystems.nixos-testing.modules;
        };
        liminality-srv1 = {
          deployment = {
            targetHost = "152.53.82.201";
            targetUser = "root";
          };
          imports = nixosSystems.liminality-srv1.modules;
        };
      };
      devShells = flake-utils.lib.eachDefaultSystemPassThrough (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
        deploy = pkgs.writeShellScriptBin "deploy" ''
          if [ $# -lt 2 ]; then
            echo "Usage: deploy <HOSTNAME> <HOST> [args...]"
            exit 1
          fi
          end
          SYS=$1
          HOST=$2
          shift 2
          ${pkgs.nixos-anywhere.outPath}/bin/nixos-anywhere \
            --flake .#$SYS \
            --copy-host-keys \
            --generate-hardware-config nixos-facter ./hosts/$SYS/facter.json \
            $HOST \
            $@
        '';
        deployVariant = profile: deployment: pkgs.writeShellScriptBin "deploy-${profile}" ''
          ${deploy}/bin/deploy ${profile} ${deployment.targetUser}@${deployment.targetHost} $@
        '';
        deployments = pkgs.lib.filterAttrs (name: config: pkgs.lib.hasAttr "deployment" config) outputs.colmena;
        age-keyscan = pkgs.writeShellScriptBin "age-keyscan" ''
          ssh-keyscan $1 | ${pkgs.ssh-to-age}/bin/ssh-to-age
        '';
      in
        with pkgs; {
          ${system}.default = mkShell {
            buildInputs = with pkgs; [
              alejandra.defaultPackage.${system}
              colmena
              home-manager.defaultPackage.${system}
              nixfmt
              nixos-anywhere.outPath
              nixos-rebuild
              nixos-rebuild
              shellcheck
              shfmt
              sops
            ];
            packages = [
              age-keyscan
              deploy
            ] ++ lib.mapAttrsToList (name: config: deployVariant name config.deployment) deployments;
          };
        });
    };
}
