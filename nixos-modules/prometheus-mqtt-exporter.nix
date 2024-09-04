{ pkgs, ... }:

{
  systemd.services.prometheus-mqtt-exporter = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.prometheus-mqtt-exporter.out}/bin/mqtt-exporter";

      Environment = [
        "MQTT_USERNAME=hass"
        "MQTT_PASSWORD=passw0rd"
        "MQTT_ADDRESS=127.0.0.1"
        "PROMETHEUS_PORT=9031"
        "LOG_LEVEL=WARNING"
        "ZIGBEE2MQTT_AVAILABILITY=True"
        "MQTT_IGNORED_TOPICS=zigbee2mqtt_bridge,zigbee2mqtt_bridge_definitions,homeassistant*"
      ];
    };
  };
}
