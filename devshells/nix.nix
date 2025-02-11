{
  perSystem,
  pkgs,
  ...
}:
with pkgs;
  mkShell {
    packages = [
      nil
      nixfmt-rfc-style
      perSystem.alejandra.default
    ];
  }
