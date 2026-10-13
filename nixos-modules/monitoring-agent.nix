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

      // The incus guests run this same node exporter, so both they and the
      // physical hosts emit node_* series with job="integrations/unix". Mark
      // this host's series so the physical-node dashboards can tell them apart
      // from the guests (which are tagged node_type="container").
      rule {
        target_label = "node_type"
        replacement  = "host"
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
