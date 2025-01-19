{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./applications
    ./programming
    ./repositories
    ./shell
  ];
  # Fix for news missing error
  news = {
    display = "silent";
    entries = lib.mkForce [];
  };
}
