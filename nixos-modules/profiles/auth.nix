{ config, lib, ... }:

let
  cfg = config.profiles.auth;
  inherit (lib) types mkOption mkEnableOption mkIf;
in
{
  options = {
    profiles.auth = {
      enable = mkEnableOption "auth";
      domain = mkOption {
        type = types.str;
      };
      listen_http = mkOption {
        type = types.str;
        default = "127.0.0.1:9000";
      };
      listen_metrics = mkOption {
        type = types.str;
        default = "127.0.0.1:9300";
      };
    };
  };

  config = mkIf cfg.enable {
    services.authentik = {
      enable = true;
      settings = {
        listen = {
          listen_http = cfg.listen_http;
          listen_metrics = cfg.listen_metrics;
        };
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://" + cfg.listen_http;
      };
    };

    services.prometheus.scrapeConfigs = [{ job_name = "authentik"; static_configs = [{ targets = [ cfg.listen_metrics ]; }]; }];
  };
}
