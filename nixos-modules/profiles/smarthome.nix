{ inputs, config, lib, pkgs, ... }:

let
  cfg = config.profiles.smarthome;
  inherit (lib) mkIf mkEnableOption;

  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
in
{
  options.profiles.smarthome = {
    enable = mkEnableOption "Enable monitoring";
  };
  config = mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      listeners = [{
        acl = [ "pattern readwrite #" ];
        users.p1ib.password = "passw0rd";
        users.z2m.password = "passw0rd";
        users.hass.password = "passw0rd";
        users.nr.password = "passw0rd";
      }];
    };

    services.nginx.virtualHosts."zigbee2mqtt.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.zigbee2mqtt.settings.frontend.port}";
      };
    };

    services.zigbee2mqtt = {
      enable = true;
      package = pkgs-unstable.zigbee2mqtt;
      settings = {
        frontend.port = 8099;
        homeassistant = true;
        mqtt = {
          server = "mqtt://adama:1883";
          user = "z2m";
          password = "passw0rd";
        };
        serial.adapter = "ember";
        advanced = {
          pan_id = 56089;
          ext_pan_id = [ 154 147 150 234 96 16 140 189 ];
          network_key = "!" + config.age.secrets.z2m.path + " network_key";
          channel = 11;
          last_seen = "ISO_8601";
          log_level = "warning";
        };
        availability = true;
      };
    };

    services.nginx.virtualHosts."node-red.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.node-red.port}";
      };
    };

    services.node-red = {
      enable = true;
      withNpmAndGcc = true;
      configFile = ./nodered-settings.js;
    };
    systemd.services.node-red.environment.NODE_PATH = let
      pkg = (pkgs.callPackage ../../pkgs/passport-openidconnect {}).package;
    in
    "${pkg.outPath}/lib/node_modules";
  };
}
