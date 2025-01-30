{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.acme.greetd;
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in {
  options.acme.greetd = {
    enable = lib.mkEnableOption "greetd.";
    sessions = lib.mkOption {
      type = lib.types.str;
      default = hyprland-session;
      description = "Path to wayland sessions, defaults to hyprland";
    };
  };
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session";
          user = "greeter";
        };
      };
    };
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
