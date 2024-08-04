{ config, lib, ... }:

let
  cfg = config.profiles.monitoring;
  inherit (lib) types mkOption mkIf mkEnableOption;
in
{
  options.profiles.monitoring = {
    enable = mkEnableOption "Enable Grafana";
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
    services.grafana = {
      enable = true;
      settings = {
        server = {
          inherit (cfg) domain root_url;
          http_port = 3000;
          http_addr = "0.0.0.0";
        };
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
