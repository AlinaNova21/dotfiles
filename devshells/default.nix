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
    }
