{
  flake,
  lib,
  pkgs,
  ...
}: {
  imports = [
    flake.homeModules.default
    flake.homeModules.nixos
  ];
  acme.desktop.enable = true;
  acme.dev.enable = true;
  acme.testing.enable = true;

  acme.hyprland.enable = true;
  acme.hyprpanel.enable = true;

  programs.zsh.initContent = ''
    eval "$(fnm env --use-on-cd --shell zsh)"
  '';
  # programs.git.signing = {
  #   signByDefault = true;
  #   key = "07D6E31CCAE33514";
  # };

  # Battery-based keyboard LED control
  systemd.user.services.battery-led-monitor = {
    Unit = {
      Description = "ASUS Keyboard LED Battery Monitor";
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "battery-led-monitor" ''
        #!/usr/bin/env bash

        BATTERY_PATH="/sys/class/power_supply/BAT0"
        CAPACITY_FILE="$BATTERY_PATH/capacity"
        STATUS_FILE="$BATTERY_PATH/status"
        STATE_FILE="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/battery-led-state"

        # Check if battery exists
        if [[ ! -f "$CAPACITY_FILE" ]]; then
          echo "Battery not found at $CAPACITY_PATH"
          exit 1
        fi

        CAPACITY=$(cat "$CAPACITY_FILE")
        STATUS=$(cat "$STATUS_FILE")
        PREVIOUS_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

        # Determine desired state
        if [[ "$CAPACITY" -le 20 ]] && [[ "$STATUS" != "Charging" ]]; then
          DESIRED_STATE="low"
        else
          DESIRED_STATE="normal"
        fi

        # Only change LED mode if state changed (avoid unnecessary writes)
        if [[ "$DESIRED_STATE" != "$PREVIOUS_STATE" ]]; then
          if [[ "$DESIRED_STATE" == "low" ]]; then
            # Low battery: red breathing
            ${pkgs.asusctl}/bin/asusctl led-mode breathe -c FF0000
            echo "Battery low ($CAPACITY%) - Setting red breathing mode"
          else
            # Normal: purple static
            ${pkgs.asusctl}/bin/asusctl led-mode static -c 9D4EDD
            echo "Battery normal ($CAPACITY%) - Setting purple static mode"
          fi

          # Save current state
          echo "$DESIRED_STATE" > "$STATE_FILE"
        fi
      '';
    };
  };

  systemd.user.timers.battery-led-monitor = {
    Unit = {
      Description = "Timer for ASUS Keyboard LED Battery Monitor";
    };
    Timer = {
      OnBootSec = "30s";
      OnUnitActiveSec = "60s";
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
}

