{perSystem, pkgs, ...}:
with pkgs;
  mkShell {
    buildInputs = [
      nil
      nixfmt-rfc-style
      perSystem.alejandra.default
    ];
  }
