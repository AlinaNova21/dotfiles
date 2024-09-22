{ inputs, globals, overlays, ... }:
with inputs;
nix-darwin.lib.system {
  system = "aarh64-darwin";
  modules = [
    ../../modules/common
    ../../modules/darwin
    (
      globals
      // rec {
        user = "Alina.Shumann";
        gitName = "Alina Shumann";
        gitEmail = "${user}@kyndryl.com";
      }
    )
    inputs.home-manager.darwinModules.home-manager
  ];
}