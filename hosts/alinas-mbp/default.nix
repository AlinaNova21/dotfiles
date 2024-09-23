{ inputs, globals, overlays, ... }:
with inputs;
nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    (
      globals
      // rec {
        user = "alinashumann";
        gitName = "Alina Shumann";
        gitEmail = "Alina.Shumann@kyndryl.com";
      }
    )
    ../../modules/common
    ../../modules/darwin
    inputs.home-manager.darwinModules.home-manager
  ];
}