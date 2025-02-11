{
  imports = [
    ./monitoring.nix
  ];
  config = {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/grafana"
        "/var/lib/loki"
        "/var/lib/prometheus2"
      ];
    };
    services.grafana = {
      enable = true;
      settings.server.http_addr = "0.0.0.0";
    };
    services.loki = {
      enable = false;
      configuration = {
        auth_enabled = false;
        server = {
          http_listen_addr = "0.0.0.0";
          http_listen_port = 3100;
          grpc_listen_port = 9096;
          log_level = "debug";
          grpc_server_max_concurrent_streams = 1000;
        };
        common = {
          instance_addr = "127.0.0.1";
          path_prefix = "/var/lib/loki";
          storage = {
            filesystem = {
              chunks_directory = "/var/lib/loki/chunks";
              rules_directory = "/var/lib/loki/rules";
            };
          };
          replication_factor = 1;
          ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
    };
    services.prometheus = {
      enable = true;
      port = 9090;
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = ["localhost:9090"];
            }
          ];
        }
        {
          job_name = "consul";
          consul_sd_configs = [
            {
              server = "localhost:8500";
              tags = ["metrics"];
            }
          ];
          # relabel_configs = [
          #   {
          #     action = "keep";
          #     source_labels = ["__meta_consul_tags"];
          #     regex = "metrics";
          #   }
          # ];
        }
      ];
    };
    acme.consul.services = [
      {
        id = "grafana";
        name = "grafana";
        tags = [
          "traefik.enable=true"
          "metrics"
          "http"
        ];
        address = "monitoring";
        port = 3000;
      }
      {
        id = "loki";
        name = "loki";
        tags = [
          "traefik.enable=true"
          "metrics"
          "http"
        ];
        address = "monitoring";
        port = 3100;
      }
    ];
  };
}
