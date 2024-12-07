{ inputs, config, lib, ... }:

let
  cfg = config.profiles.auth;
  inherit (lib) types mkOption mkEnableOption mkIf;
in
{
  imports = [
    inputs.authentik-nix.nixosModules.default
  ];
  options = {
    profiles.auth = {
      enable = mkEnableOption "auth";
      domain = mkOption {
        type = types.str;
      };
      listen_http = mkOption {
        type = types.str;
        default = "0.0.0.0:9000";
      };
      listen_metrics = mkOption {
        type = types.str;
        default = "0.0.0.0:9300";
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."authentik.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:9000";
      };
    };

    services.authentik = {
      enable = true;
      settings = {
        listen = {
          inherit (cfg) listen_http;
          inherit (cfg) listen_metrics;
        };
      };
    };

    systemd.services.authentik.environment.AUTHENTIK_LOG_LEVEL = "warning";
    systemd.services.authentik-worker.environment.AUTHENTIK_LOG_LEVEL = "warning";

    services.redis.servers.authentik.logLevel = "warning";
    services.postgresql.settings.log_checkpoints = false;

    services.prometheus = {
      exporters = {
        redis.enable = true;
        postgres = { enable = true; runAsLocalSuperUser = true; };
      };
      scrapeConfigs = [
        { job_name = "authentik"; static_configs = [{ targets = [ "127.0.0.1:9300" ]; }]; }
        { job_name = "redis"; static_configs = [{ targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.redis.port}" ]; }]; }
        { job_name = "postgres"; static_configs = [{ targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.postgres.port}" ]; }]; }
      ];
    };
  };
}
