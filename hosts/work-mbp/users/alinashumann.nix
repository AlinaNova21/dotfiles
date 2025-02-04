{flake, ...}: {
  imports = [
    flake.homeModules.default
  ];
  acme.dev.enable = true;
  acme.docker.enable = true;
  acme.git.email = "Alina.Shumann@kyndryl.com";
  programs.git.ignores = [".envrc" "flake.nix" "flake.lock"];
}
