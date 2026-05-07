{
  perSystem,
  pkgs,
  ...
} @ inputs:
  with pkgs;
    mkShell {
      inputsFrom = [
        (import ./nix.nix inputs)
      ];
      packages = [
        perSystem.home-manager.default
      ];
    }
