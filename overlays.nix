{ pkgs, config, ... }:
let
  unstable-pkgs = import config.nixpkgs-unstable-path { inherit (pkgs.stdenv) system; };
in
{
  nixpkgs.overlays = [
    (_final: prev: {
      nodePackages = prev.nodePackages // {
        passport-openidconnect = (prev.callPackage ./pkgs/passport-openidconnect { }).package;
      };
      audi_connect_ha = prev.callPackage ./pkgs/audi_connect_ha.nix { };
      easee_hass = unstable-pkgs.callPackage ./pkgs/easee_hass.nix { inherit (config) pyproject-nix-lib; };

      darwin = prev.darwin.overrideScope (_: _: {
        inherit (unstable-pkgs.darwin) linux-builder;
      });

      inherit (unstable-pkgs) home-assistant;
      inherit (unstable-pkgs) zigbee2mqtt;
    })
  ];
}
