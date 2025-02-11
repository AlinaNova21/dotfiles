{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  watchdog = config.services.space-station-14-watchdog;
  error-pages-files = pkgs.fetchzip {
    url = "https://github.com/tarampampam/error-pages/releases/download/v3.3.1/error-pages-static.zip";
    hash = "sha256-wZtQjIHc5ky3Cf4BVob6H8eD1CHzlCNIuhizr1CP6d8=";
    stripRoot = false;
  };
  error-pages-conf = ''
    error_page 401 /_error-pages/401.html;
    error_page 403 /_error-pages/403.html;
    error_page 404 /_error-pages/404.html;
    error_page 500 /_error-pages/500.html;
    error_page 502 /_error-pages/502.html;
    error_page 503 /_error-pages/503.html;

    location ^~ /_error-pages/ {
      internal;
      rewrite  ^/_error-pages/(.*) /$1 break;
      root ${error-pages-files}/lost-in-space;
    }
  '';
in {
  imports = [
    ./admin.nix
    ./cdn.nix
    ./postgres.nix
    ./watchdog.nix
  ];
  users.users.ss14 = {
    isSystemUser = true;
    group = "ss14";
    uid = 1654;
  };
  users.groups.ss14 = {
    gid = 1654;
  };
  sops.secrets.ss14cert = {
    format = "yaml";
    sopsFile = ../../../secrets/ss14certs.yaml;
    key = "cert";
    uid = config.users.users.nginx.uid;
  };
  sops.secrets.ss14key = {
    format = "yaml";
    sopsFile = ../../../secrets/ss14certs.yaml;
    key = "key";
    uid = config.users.users.nginx.uid;
  };
  sops.secrets.ss14admin = {
    format = "yaml";
    sopsFile = ../../../secrets/ss14admin.yaml;
    key = "";
    owner = config.users.users.ss14.name;
    group = config.users.users.ss14.group;
  };
  services.space-station-14-admin = {
    enable = true;
    settings = {
      ConnectionStrings.DefaultConnection = "Server=10.88.0.1;Port=5432;Database=ss14;User Id=postgres;Password=postgres";
      AllowedHosts = "central.liminality-project.space";
      ForwardProxies = ["10.88.0.1"];
    };
    secrets = config.sops.secrets.ss14admin.path;
  };
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
    recommendedTlsSettings = true;
    virtualHosts."cdn.liminality-project.space" = {
      sslCertificate = config.sops.secrets.ss14cert.path;
      sslCertificateKey = config.sops.secrets.ss14key.path;
      onlySSL = true;
      extraConfig = error-pages-conf;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = ''
          proxy_pass_header Authorization;
        '';
      };
    };
    virtualHosts."direct.cdn.liminality-project.space" = {
      extraConfig = error-pages-conf;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = ''
          proxy_pass_header Authorization;
        '';
      };
    };
    virtualHosts."dev1.liminality-project.space" = {
      extraConfig = error-pages-conf;
      locations."/" = {
        proxyPass = "http://127.0.0.1:1212";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig = ''
          proxy_pass_header Authorization;
        '';
      };
    };
    virtualHosts."central.liminality-project.space" = {
      sslCertificate = config.sops.secrets.ss14cert.path;
      sslCertificateKey = config.sops.secrets.ss14key.path;
      onlySSL = true;
      extraConfig = error-pages-conf;
      locations."/" = {
        proxyPass = "http://127.0.0.1:27689";

        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header X-Forwarded-Proto https;
          # Necessary to avoid errors from too large headers thanks to large cookies.
          proxy_buffer_size 128k;
          proxy_buffers 4 256k;
          proxy_busy_buffers_size 256k;
        '';
      };
    };
  };
}
