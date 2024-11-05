{ inputs, globals, overlays, ... }:
with inputs;
nix-darwin.lib.darwinSystem rec {
  system = "aarch64-darwin";
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      # make unstable packages available via overlay
      (final: prev: {
        # unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfreePredicate = pkg: true;
        };
      })
    ];
  };
  modules = [
    (
      globals // rec {
        user = "alinashumann";
        gitName = "Alina Shumann";
        gitEmail = "Alina.Shumann@kyndryl.com";
      }
    )
    ../../modules/common
    ../../modules/darwin
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.users.alinashumann = {
        programs.git.ignores = [".envrc" "flake.nix"];
      };
    }
  ];
}