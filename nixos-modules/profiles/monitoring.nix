{ config, lib, ... }:

let
  cfg = config.profiles.monitoring;
  inherit (lib) types mkOption mkIf mkEnableOption;
in
{
  options.profiles.monitoring = {
    enable = mkEnableOption "Enable Grafana";
    grafana = {
      domain = mkOption {
        type = types.str;
      };
      oauth = {
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
  };
  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          domain = cfg.grafana.domain;
          http_port = 3000;
          http_addr = "0.0.0.0";
        };
        "auth.generic_oauth" = {
          enabled = true;
          name = "Authentik";
          client_id = "$__file{${cfg.grafana.oauth.client_id_file}}";
          client_secret = "$__file{${cfg.grafana.oauth.client_secret_file}}";
          scopes = "openid email profile offline_access";
          auth_url = cfg.grafana.oauth.auth_url;
          token_url = cfg.grafana.oauth.token_url;
          api_url = cfg.grafana.oauth.api_url;
          tls_skip_verify_insecure = true;
          allow_assign_grafana_admin = true;
          role_attribute_path = "contains(groups[*], 'Grafana Admin') && 'GrafanaAdmin' || 'Viewer'";
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
          }
        ];
      };
    };

    services.nginx.virtualHosts."grafana.localho.st" = {
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}/";
      };
    };
  };
}
