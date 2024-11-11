{config, inputs, lib, pkgs, ...}: {
  home-manager.users.${config.user} = {
    programs.foot = {
      settings = {
        main = {
          font = "FiraCode Nerd Font Mono:size=8";
          dpi-aware = "yes";
        };
        mouse = {
          hide-when-typing = "yes";
        };
      };
    };
  };
}