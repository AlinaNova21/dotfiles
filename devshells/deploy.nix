{
  flake,
  perSystem,
  pkgs,
  ...
} @ inputs: let
  lib = pkgs.lib;
  # Access deployment utilities from flake.lib (Blueprint auto-discovered)
  deployUtils = flake.lib.mkDeployUtils pkgs;
in
  with pkgs;
    mkShell {
      packages =
        [
          # Core deployment tools (all platforms)
          colmena
          nixos-anywhere.outPath
          nixos-rebuild
          sops
          deployUtils.deploy
          deployUtils.age-keyscan
        ]
        # Generated deployment scripts
        ++ deployUtils.allDeployScripts
        ++ deployUtils.allSwitchScripts;
    }
