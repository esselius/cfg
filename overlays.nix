{ inputs, pkgs, ... }:
let
  unstable-pkgs = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      prometheus-mqtt-exporter = unstable-pkgs.callPackage ./pkgs/prometheus-mqtt-exporter.nix { };

      nodePackages = prev.nodePackages // {
        passport-openidconnect = (prev.callPackage ./pkgs/passport-openidconnect { }).package;
      };
      audi_connect_ha = prev.callPackage ./pkgs/audi_connect_ha.nix {};

      darwin = prev.darwin.overrideScope (_: _: {
        inherit (unstable-pkgs.darwin) linux-builder;
      });

      inherit (unstable-pkgs) home-assistant;
      inherit (unstable-pkgs) zigbee2mqtt;
      # inherit (unstable-pkgs) grafana-alloy;
    })
  ];
}
