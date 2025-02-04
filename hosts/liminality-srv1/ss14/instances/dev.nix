{
  config,
  lib,
  pkgs,
  ...
}: let
  host = "dev1.liminality-project.space";
  port = 1212;
  name = "dev";
  token = "dev";
  displayName = "Liminality Project Dev";
  max_players = 30;
in {
  services.space-station-14-watchdog = {
    settings.Servers.Instances.dev = {
      Name = name;
      ApiToken = token;
      ApiPort = port;
      UpdateType = "Manifest";
      Updates.ManifestUrl = "https://cdn.liminality-project.space/fork/liminality-project/manifest";
      Updates.HybridACZ = true;
      # UpdateType = "Git";
      # Updates.BaseUrl = "https://github.com/Liminality-Project/Liminality-Project/";
      # Updates.Branch = "master";
      TimeoutSeconds = 60;
    };
    instances.dev.configuration = {
      log = {
        path = "logs";
        format = "log_%(date)s-%(time)s.txt";
        level = 2;
        enabled = true;
      };

      net = {
        tickrate = 30;
        port = port;
        bindto = "::,0.0.0.0";
        max_connections = max_players;
      };

      status = {
        enabled = true;
        bind = "*:${toString port}";
        connectaddress = "udp://${host}:${toString port}";
      };

      game = {
        hostname = displayName;
      };

      console = {
        loginlocal = true;
        login_host_user = "Elora";
      };

      hub = {
        advertise = false;
        tags = "";
        server_url = "";
        hub_urls = "https://hub.spacestation14.com/";
      };

      auth = {
        mode = 1;
      };
    };
  };
}
