{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types) enum;
in
{
  options = {
    context = mkOption {
      type = enum [ "home" "work" ];
    };
    formfactor = mkOption {
      type = enum [ "desktop" "laptop" "server" ];
    };
  };
}
