{
  perSystem,
  pkgs,
  ...
} @ inputs: let
  lib = pkgs.lib;
in
  with pkgs;
    mkShell {
      inputsFrom = [
        (import ./nix.nix inputs)
      ];
      packages =
        [
          perSystem.home-manager.default
        ]
        ++ lib.lists.optionals (!pkgs.stdenv.isDarwin) [
          nixos-rebuild
        ];
    }
