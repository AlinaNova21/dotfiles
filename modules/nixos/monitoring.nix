{
  config,
  lib,
  ...
}: {
  options.acme.consul = {
    services = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [];
      description = ''
        Services to add to consul.
      '';
    };
  };
  config = {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/consul"
      ];
    };
    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
      };
    };
    acme.consul.services = [
      {
        id = "${config.networking.hostName}-prometheus-exporter";
        name = "${config.networking.hostName}-prometheus-exporter";
        tags = ["metrics"];
        address = config.networking.hostName;
        port = 9002;
      }
    ];
    services.consul = {
      enable = true;
      extraConfig = {
        # node_name = "node-${config.networking.hostName}";
        data_dir = "/persist/var/lib/consul";
        addresses = {
          http = "0.0.0.0";
        };
        retry_join = ["dockge"];
        advertise_addr = "{{ GetInterfaceIP \"tailscale0\" }}";
        connect = {
          enabled = true;
        };
        services = config.acme.consul.services;
      };
    };
  };
}
