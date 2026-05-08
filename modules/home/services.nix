{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.services;
in {
  options.acme.services = {
    opencode = lib.mkEnableOption "OpenCode server";
  };

  config = lib.mkIf cfg.opencode {
    systemd.user.services.opencode = {
      Unit = {
        Description = "OpenCode AI server";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.opencode}/bin/opencode serve --port 4096 --hostname 0.0.0.0";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}