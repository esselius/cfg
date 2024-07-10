{ config, lib, ... }:

let
  cfg = config.profiles.auth;
  inherit (lib) types mkOption mkEnableOption mkIf;
in
{
  options = {
    profiles.auth = {
      enable = mkEnableOption "auth";
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
    services.authentik = {
      enable = true;
      settings = {
        listen = {
          listen_http = cfg.listen_http;
          listen_metrics = cfg.listen_metrics;
        };
      };
    };

    services.prometheus.scrapeConfigs = [{ job_name = "authentik"; static_configs = [{ targets = [ cfg.listen_metrics ]; }]; }];
  };
}
