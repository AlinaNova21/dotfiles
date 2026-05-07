{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.desktop.services;
in {
  options.acme.desktop.services = {
    awww = lib.mkEnableOption "awww wallpaper daemon";
    mako = lib.mkEnableOption "mako notification daemon";
    ashell = lib.mkEnableOption "ashell status bar";
  };

  config = lib.mkIf config.acme.desktop.enable {
    systemd.user.services.awww = lib.mkIf cfg.awww {
      Unit = {
        Description = "awww wallpaper daemon";
        After = ["graphical-session.target"];
        PartOf = ["niri.service"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        ExecStartPost = "${pkgs.awww}/bin/awww restore";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["niri.service"];
    };

    services.mako = lib.mkIf cfg.mako {
      enable = true;
      settings = {
        border-radius = 8;
      };
    };

    systemd.user.services.mako = lib.mkIf cfg.mako {
      Unit = {
        Description = "mako notification daemon";
        After = ["graphical-session.target"];
        PartOf = ["niri.service"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.mako}/bin/mako";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["niri.service"];
    };

    systemd.user.services.ashell = lib.mkIf cfg.ashell {
      Unit = {
        Description = "ashell status bar";
        After = ["graphical-session.target"];
        PartOf = ["niri.service"];
      };
      Service = {
        Type = "simple";
        ExecStart = "/usr/bin/ashell";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["niri.service"];
    };
  };
}