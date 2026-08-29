{
  flake,
  lib,
  ...
}: {
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];

  # MISE MIGRATION: acme.* home-manager management fully disabled (option a).
  # User config (dotfiles/tools/zsh/git/...) is now managed by mise (bootstrap via .mise/,
  # runtime via .config/mise/). Services gated by acme (auto-upgrade, opencode) stop.
  # Set true to re-enable specific pieces during migration/rollback.
  acme.desktop.enable = false;
  acme.dev.enable = false;
  acme.testing.enable = false;
  acme.autoUpgrade.enable = false;
  acme.services.opencode = false;
  acme.tools.kubernetes.enable = false;

  # Disable Hyprland and Hyprpanel nix management on this host
  #acme.hyprland.enable = lib.mkForce false;
  #acme.hyprpanel.enable = lib.mkForce false;

  # Stale nix zsh/git overrides (superseded by mise-managed .zshrc/.config/git) removed.
  # programs.zsh.initContent = '' eval "$(fnm env --use-on-cd --shell zsh)" '';
  # programs.git.signing = { ... };
}