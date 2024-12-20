{ inputs, globals, overlays, ... }:
with inputs;
nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    globals
    home-manager.nixosModules.home-manager
    
    # ./modules/tailscale.nix
    ../../modules/common
    ../../modules/nixos
    ({config, lib, pkgs, ...}: {
      passwordHash = "$6$NTUzZTYyYjI$yI3zdkAdbXoq4m4PppDjvsfjkHfdsu4F/8pZhogkRfvX1SHk/j1Jmq6OcCyx8.GRylSVAX1PfwbYJVtPnGM7d0";
      kubernetes.enable = true;
      tailscale.enable = true;
      steam.enable = true;
      gui.enable = true;
      unfreePackages = [
        "vscode"
      ];
      # hyprland.enable = true;
      environment.systemPackages = with pkgs; [
        mesa
        libdrm
        intel-media-driver
        libvdpau-va-gl
      ];
      security.polkit.enable = true;
      home-manager.users.${globals.user} = {
        programs.vscode = {
          enable = true;
          extensions = with pkgs.vscode-extensions; [
            mkhl.direnv
            bbenoist.nix
          ];
        };
        wayland.windowManager.hyprland = {
          enable = false;
          # set the flake package
          package = inputs.hyprland.packages.${system}.hyprland;
        #   settings = {
        #     env = [
        #       "LIBVA_DRIVER_NAME,nvidia"
        #       "XDG_SESSION_TYPE,wayland"
        #       "GBM_BACKEND,nvidia-drm"
        #       "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        #     ];
            
        #     monitor = [
        #       "Unknown-1,disabled"
        #       "HEADLESS-2,1920x1080@60,0x0,1"
        #     ];

        #     cursor = {
        #       no_hardware_cursors = true;
        #     };
        #  };
        };
        home.packages = with pkgs; [
	  kitty
          # sunshine
        ];
        # systemd.user.services.sunshine = {
        #   Unit = {
        #     Description = "Sunshine self-hosted game stream host for Moonlight.";
        #     StartLimitIntervalSec = 30;
        #     StartLimitBurst = 5;
        #   };
        #   Install = {
        #     WantedBy = [ "graphical-session.target" ];
        #   };
        #   Service = {
        #     AmbientCapabilities="CAP_SYS_ADMIN";
        #     ExecStart = "${pkgs.sunshine}/bin/sunshine";
        #     Restart = "on-failure";
        #     RestartSec = "5s";
        #     User = "alina";
        #   };
        # };
      };
    })
  ];
  # home-manager.users.${globals.user}.home = ../../home.personal.nix;
}
