{
  perSystem,
  pkgs,
  ...
}:
with pkgs;
  mkShell {
    packages = [
      nil
      nixfmt
      perSystem.alejandra.default
    ];
  }
