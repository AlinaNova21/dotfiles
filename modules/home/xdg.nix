{ config, ... }: {
  xdg.userDirs.enable = true;
  xdg.userDirs.projects = "${config.home.homeDirectory}/projects";
}
