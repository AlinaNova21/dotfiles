{
  flake,
  inputs,
  ...
}: let
  # Import nixpkgs to get pkgs and lib
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
  };
  lib = pkgs.lib;
in {
  # Helper to create deployment utilities for a given pkgs instance
  # This allows the devshell to pass its own pkgs (with correct system)
  mkDeployUtils = pkgs: let
    lib = pkgs.lib;
  in rec {
    # Core deployment wrapper
    deploy = pkgs.writeShellScriptBin "deploy" ''
      if [ $# -lt 2 ]; then
        echo "Usage: deploy <HOSTNAME> <HOST> [args...]"
        exit 1
      fi
      SYS=$1
      HOST=$2
      shift 2
      ${pkgs.nixos-anywhere.outPath}/bin/nixos-anywhere \
        --flake .#$SYS \
        --copy-host-keys \
        $HOST \
        $@
    '';

    # Age key scanning utility
    age-keyscan = pkgs.writeShellScriptBin "age-keyscan" ''
      ssh-keyscan $1 | ${pkgs.ssh-to-age}/bin/ssh-to-age
    '';

    # Script generator for deployment
    deployVariant = profile: deployment:
      pkgs.writeShellScriptBin "deploy-${profile}" ''
        ${deploy}/bin/deploy ${profile} ${deployment.targetUser}@${deployment.targetHost} $@
      '';

    # Script generator for switching
    switchVariant = profile: deployment:
      pkgs.writeShellScriptBin "switch-${profile}" ''
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake '.#${profile}' --target-host ${deployment.targetUser}@${deployment.targetHost} $@
      '';

    # Extract deployments from hive
    deployments = lib.filterAttrs
      (name: config: lib.hasAttr "deployment" config)
      flake.colmena;

    # Generate all deployment scripts
    allDeployScripts = lib.mapAttrsToList
      (name: config: deployVariant name config.deployment)
      deployments;

    # Generate all switch scripts
    allSwitchScripts = lib.mapAttrsToList
      (name: config: switchVariant name config.deployment)
      deployments;
  };
}
