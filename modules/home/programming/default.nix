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
    ./langs.nix
    ./nvim.nix
    ./onepassword.nix
  ];
}
