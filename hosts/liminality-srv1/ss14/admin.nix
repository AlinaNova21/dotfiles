{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.space-station-14-admin;
  appsettingsFile =
    pkgs.writeText "appsettings.json"
    (builtins.toJSON (attrsets.recursiveUpdate appsettingsDefaults cfg.settings));
  appsecretsFile = pkgs.writeText "appsettings.json" "";
  appsettingsDefaults = {
    Serilog = {
      Using = ["Serilog.Sinks.Console"];
      MinimumLevel = {
        Default = "Information";
        Override = {
          SS14 = "Debug";
          Microsoft = "Warning";
          "Microsoft.Hosting.Lifetime" = "Information";
          "Microsoft.AspNetCore" = "Warning";
          IdentityServer4 = "Warning";
        };
      };
      WriteTo = [
        {
          Name = "Console";
          Args = {
            OutputTemplate = "[{Timestamp:HH:mm:ss} {Level:u3} {SourceContext}] {Message:lj}{NewLine}{Exception}";
          };
        }
      ];
      Enrich = ["FromLogContext"];
    };
    ConnectionStrings = {
      DefaultConnection = "Server=127.0.0.1;Port=5432;Database=ss14;User Id=ss14-admin;Password=foobar";
    };
    AllowedHosts = "central.spacestation14.io";
    urls = "http://0.0.0.0:27689/";
    PathBase = "/";
    WebRootPath = "/app/wwwroot";
    ForwardProxies = ["127.0.0.1"];
    authServer = "https://auth.spacestation14.com";
  };
in {
  options = {
    services.space-station-14-admin = {
      enable = mkEnableOption "space-station-14-admin";
      settings = mkOption {
        type = (pkgs.formats.yaml {}).type;
        default = {};
        description = lib.mkDoc ''
          SS14.Admin settings. Mapped to appsettings.yml.
        '';
      };
      secrets = mkOption {
        type = types.path;
        default = appsecretsFile;
        description = lib.mkDoc ''
          Path to secrets to include
        '';
      };
      port = mkOption {
        type = lib.types.port;
        default = 27689;
        description = lib.mkDoc ''
          Port to bind the Admin server to.
        '';
      };
    };
  };
  config = lib.mkIf (cfg.enable) {
    virtualisation.oci-containers.containers.admin = {
      serviceName = "space-station-14-admin";
      image = "ghcr.io/space-wizards/ss14.admin";
      volumes = [
        "${appsettingsFile}:/app/appsettings.yml"
        "${cfg.secrets}:/app/appsettings.Secret.yml:ro"
      ];
      ports = ["${toString cfg.port}:27689"];
    };
  };
}
