{
  acme.gitEmail = "Alina.Shumann@kyndryl.com";
  acme.user = "alinashumann";
  acme.role = "dev";

  home-manager.users.alinashumann = import ../../home "darwin" "alinashumann" {
    programs.git.ignores = [".envrc" "flake.nix"];

    acme.docker.enable = true;
  };

  system.stateVersion = "24.11";
}
