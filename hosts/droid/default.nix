{
  home-manager.users.alina = import ../../home "nixOnDroid" "alina" {
    acme.dev.enable = true;
  };

  system.stateVersion = "24.11";
}
