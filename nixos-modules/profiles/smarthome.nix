{ inputs, config, lib, pkgs, ... }:

let
  cfg = config.profiles.smarthome;
  inherit (lib) mkIf mkEnableOption;

  unstable-pkgs = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
  inherit (unstable-pkgs) zigbee2mqtt;
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

    services.zigbee2mqtt = {
      enable = true;
      package = zigbee2mqtt;
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
          network_key = "!" + config.age.secrets.z2m.path +  " network_key";
          channel = 11;
          last_seen = "ISO_8601";
          log_level = "warning";
        };
        availability = true;
      };
    };

    services.node-red = {
      enable = true;
      withNpmAndGcc = true;
    };
  };
}
