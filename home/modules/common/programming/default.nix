{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./direnv.nix
    ./helix.nix
    ./kubernetes.nix
    ./gh.nix
  ];
  home.packages = [
    inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system}
  ];
}
