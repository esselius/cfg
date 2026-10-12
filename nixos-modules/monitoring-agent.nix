{ config, ... }:
let
  hostName = config.networking.hostName;
in
{
  services.alloy.enable = true;

  environment.etc."alloy/config.alloy".text = ''
    prometheus.exporter.unix "node" {
      enable_collectors = ["systemd"]
    }

    prometheus.scrape "node" {
      targets    = prometheus.exporter.unix.node.targets
      forward_to = [prometheus.relabel.host.receiver]
    }

    prometheus.relabel "host" {
      forward_to = [prometheus.remote_write.default.receiver]
      rule {
        target_label = "host"
        replacement  = "${hostName}"
      }
    }

    prometheus.remote_write "default" {
      endpoint {
        url = "http://monitoring.int.esselius.dev:8428/api/v1/write"
      }
    }

    loki.source.journal "journal" {
      forward_to = [loki.write.default.receiver]
      labels     = { host = "${hostName}", job = "systemd-journal" }
    }

    loki.write "default" {
      endpoint {
        url = "http://monitoring.int.esselius.dev:3100/loki/api/v1/push"
      }
    }
  '';
}
