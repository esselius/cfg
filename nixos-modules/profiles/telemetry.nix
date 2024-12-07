{ config, lib, ... }:

let
  cfg = config.profiles.telemetry;
in
{
  options.profiles.telemetry = {
    enable = lib.mkEnableOption "Enable telemetry";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9090;

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
      ];
    };
  };
}
