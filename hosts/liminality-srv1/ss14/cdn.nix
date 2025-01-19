{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.robust-cdn;
  appsettingsFile =
    pkgs.writeText "appsettings.json"
    (builtins.toJSON (attrsets.recursiveUpdate appsettingsDefaults cfg.settings));
  appsettingsDefaults = {
    Logging.LogLevel = {
      Default = "Information";
      "Microsoft.AspNetCore" = "Warning";
      Robust = "Information";
    };
    Cdn.StreamCompressLevel = 5;
    PathBase = "/";
    BaseUrl = "http://127.0.0.1:5000/";
    AllowedHosts = "*";
  };
in {
  options = {
    services.robust-cdn = {
      enable = mkEnableOption "robust-cdn";
      settings = mkOption {
        type = (pkgs.formats.yaml {}).type;
        default = {};
        description = lib.mkDoc ''
          Robust CDN settings. Mapped to appsettings.yml.
        '';
      };
      port = mkOption {
        type = lib.types.port;
        default = 8080;
        description = lib.mkDoc ''
          Port to bind the CDN server to.
        '';
      };
      dataDir = mkOption {
        type = lib.types.path;
        default = "/var/lib/robust-cdn";
        description = lib.mkDoc ''
          Directory to store CDN data in.
        '';
      };
    };
  };
  config = lib.mkIf (cfg.enable) {
    virtualisation.oci-containers.containers.cdn = {
      serviceName = "robust-cdn";
      image = "ghcr.io/space-wizards/robust.cdn:2";
      user = "1654:1654";
      volumes = [
        "${appsettingsFile}:/app/appsettings.json"
        "${cfg.dataDir}/builds:/builds"
        "${cfg.dataDir}/manifest:/manifest"
        "${cfg.dataDir}/database:/database"
      ];
      ports = ["${toString cfg.port}:8080"];
    };
    system.activationScripts.makeRobustCdnDir = lib.stringAfter ["var"] ''
      mkdir -p ${cfg.dataDir}/{builds,manifest,database}
      chown -R 1654:1654 ${cfg.dataDir}
    '';
  };
}
