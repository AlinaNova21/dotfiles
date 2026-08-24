{ config, ... }:
{
  # DISABLED (mise migration, Stage 3): user-dirs.conf/.dirs are now mise dotfiles
  # (repo .config/user-dirs/ → ~/.config/user-dirs.*). nix xdg.userDirs no longer generates them.
  # xdg.userDirs.enable = true;
  # xdg.userDirs.projects = "${config.home.homeDirectory}/projects";
}
