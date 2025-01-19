{
  config,
  lib,
  ...
}:
with lib; let
  watchdog = config.services.space-station-14-watchdog;
in {
  imports = [
    ./cdn.nix
    ./watchdog.nix
  ];
  services.robust-cdn = {
    enable = true;
    dataDir = "/persist/var/lib/robust-cdn";
    settings = {
      Manifest.Forks.liminality-project = {
        UpdateToken = "a4b001b1c3cfc40147ffe940ed73dc72a96a44e2d7b0afd37b4eb37a431c314c";
        NotifyWatchdogs =
          [
            {
              WatchdogUrl = "http://ss14-dev:5000/";
              Instance = "dev";
              ApiToken = "dev";
            }
          ]
          ++ attrsets.mapAttrsToList (name: value: {
            WatchdogUrl = watchdog.settings.BaseUrl;
            Instance = name;
            ApiToken = value.ApiToken;
          })
          watchdog.settings.Servers.Instances;
        Private = false;
        PruneBuildsDays = 90;
        DisplayName = "Liminality Project";
        BuildsPageLink = "https://liminality-project.space";
        BuildsPageLinkText = "Liminality Project";
      };
      Cdn.StreamCompressLevel = 5;
      BaseUrl = "https://cdn.liminality-project.space/";
      PathBase = "/";
      AllowedHosts = "*";
    };
  };
  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx = {
    enable = true;
    clientMaxBodySize = "1G";
    recommendedProxySettings = true;
    virtualHosts."cdn.liminality-project.space" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = "proxy_pass_header Authorization;";
      };
    };
    virtualHosts."direct.cdn.liminality-project.space" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = "proxy_pass_header Authorization;";
      };
    };
    virtualHosts."dev1.liminality-project.space" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:1212";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = "proxy_pass_header Authorization;";
      };
    };
  };
}
