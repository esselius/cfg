{ inputs, config, lib, ... }:

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
      }];
    };
    services.zigbee2mqtt = {
      enable = true;
      package = zigbee2mqtt
    };
  };
}
