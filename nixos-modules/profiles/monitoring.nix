{ config, lib, ... }:

let
  cfg = config.profiles.monitoring;
  inherit (lib) types mkOption mkIf mkEnableOption;
in
{
  options.profiles.monitoring = {
    enable = mkEnableOption "Enable monitoring";
    domain = mkOption {
      type = types.str;
    };
    root_url = mkOption {
      type = types.str;
      default = "%(protocol)s://%(domain)s:%(http_port)s/";
    };
    oauth = {
      name = mkOption {
        type = types.str;
      };
      auth_url = mkOption {
        type = types.str;
      };
      token_url = mkOption {
        type = types.str;
      };
      api_url = mkOption {
        type = types.str;
      };
      client_id_file = mkOption {
        type = types.path;
      };
      client_secret_file = mkOption {
        type = types.path;
      };
    };
  };
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."grafana.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        recommendedProxySettings = true;
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      };
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          inherit (cfg) domain root_url;
          http_port = 3000;
          http_addr = "0.0.0.0";
        };

        security.disable_initial_admin_creation = true;

        log.level = "warn";

        "auth.generic_oauth" = {
          enabled = true;
          name = cfg.oauth.name;
          client_id = "$__file{${cfg.oauth.client_id_file}}";
          client_secret = "$__file{${cfg.oauth.client_secret_file}}";
          scopes = "openid email profile offline_access";
          auth_url = cfg.oauth.auth_url;
          token_url = cfg.oauth.token_url;
          api_url = cfg.oauth.api_url;
          tls_skip_verify_insecure = true;
          allow_assign_grafana_admin = true;
          role_attribute_path = "contains(groups[*], 'Grafana Admin') && 'GrafanaAdmin' || 'Viewer'";
        };
      };

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
          }
        ];
        dashboards.settings.providers = [{
          name = "My Dashboards";
          options.path = "/etc/grafana-dashboards";
        }];
      };
    };

    environment.etc = {
      "grafana-dashboards/node_exporter.json" = {
        source = builtins.fetchurl {
          url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
          sha256 = "0qza4j8lywrj08bqbww52dgh2p2b9rkhq5p313g72i57lrlkacfl";
        };
        user = "grafana";
        group = "grafana";
      };
    };

    services.nginx.virtualHosts."prometheus.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
      };
    };

    services.prometheus = {
      enable = true;
      port = 9001;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "cgroups"
            "systemd"
          ];
        };
      };

      scrapeConfigs = [
        { job_name = "node"; static_configs = [{ targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }]; }
        { job_name = "loki"; static_configs = [{ targets = [ "127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}" ]; }]; }
        { job_name = "promtail"; static_configs = [{ targets = [ "127.0.0.1:${toString config.services.promtail.configuration.server.http_listen_port}" ]; }]; }
      ];
    };

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 28183;
          grpc_listen_port = 0;
        };

        clients = [{ url = "http://localhost:3030/loki/api/v1/push"; }];

        scrape_configs = [{
          job_name = "journal";
          journal = {
            json = true;
            max_age = "24h";
            labels.job = "systemd-journal";
          };
        }];
      };
    };

    services.loki = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3030;
          log_level = "warn";
        };
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore.store = "inmemory";
              replication_factor = 1;
            };
            final_sleep = "0s";
          };
          chunk_idle_period = "5m";
          chunk_retain_period = "30s";
        };

        schema_config.configs = [{
          from = "2024-04-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-index";
            cache_location = "/var/lib/loki/tsdb-cache";
            cache_ttl = "24h";
          };
          filesystem.directory = "/var/lib/loki/chunks";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
    };
  };
}
