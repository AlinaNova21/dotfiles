{
  flake,
  perSystem,
  pkgs,
  ...
}: let
  lib = pkgs.lib;
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
  deployVariant = profile: deployment:
    pkgs.writeShellScriptBin "deploy-${profile}" ''
      ${deploy}/bin/deploy ${profile} ${deployment.targetUser}@${deployment.targetHost} $@
    '';
  deployments = pkgs.lib.filterAttrs (name: config: pkgs.lib.hasAttr "deployment" config) flake.colmena;
  age-keyscan = pkgs.writeShellScriptBin "age-keyscan" ''
    ssh-keyscan $1 | ${pkgs.ssh-to-age}/bin/ssh-to-age
  '';
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      nixfmt-rfc-style
      nixos-anywhere.outPath
      nixos-rebuild
      perSystem.alejandra.default
      colmena
      perSystem.home-manager.default
      sops
      shellcheck
      shfmt
    ];
    packages =
      [
        age-keyscan
        deploy
      ]
      ++ lib.mapAttrsToList (name: config: deployVariant name config.deployment) deployments;
  }
