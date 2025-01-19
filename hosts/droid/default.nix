{
  acme.role = "minimal";
  home-manager.users.alina = import ../../home "nixOnDroid" "alina" {};

  system.stateVersion = "24.11";
}
