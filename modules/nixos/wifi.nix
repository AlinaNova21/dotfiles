{
  config,
  lib,
  ...
}: let
  cfg = config.acme.wifi;
in
  with lib; {
    options.acme.wifi = {
      enable = mkEnableOption "wifi config";
    };
    config = mkIf (cfg.enable) {
      sops.secrets."wifi/home/ssid" = {};
      sops.secrets."wifi/home/psk" = {};
      hardware.enableRedistributableFirmware = true;
      networking.networkmanager.ensureProfiles = {
        environmentFiles = [
          config.sops.secrets."wifi/home/ssid".path
          config.sops.secrets."wifi/home/psk".path
        ];
        profiles = {
          home = {
            connection = {
              id = "home";
              type = "wifi";
              autoconnect = true;
            };
            ipv4 = {
              dns-search = "";
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$HOME_SSID";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
          };
        };
      };
    };
  }
