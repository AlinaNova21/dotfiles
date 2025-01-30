{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./direnv.nix
    ./docker.nix
    ./helix.nix
    ./kubernetes.nix
    ./gh.nix
  ];
  home.packages = with pkgs; [
    inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system}
  ];
}
