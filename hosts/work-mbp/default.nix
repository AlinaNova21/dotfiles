{
  acme.gitEmail = "Alina.Shumann@kyndryl.com";
  acme.user = "alinashumann";

  home-manager.users.alinashumann = import ../../home "darwin" "alina" {
    programs.git.ignores = [".envrc" "flake.nix"];
  };

  system.stateVersion = "24.11";
}
