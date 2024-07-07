{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types) enum;
in
{
  options.context = mkOption {
    type = enum [ "home" "work" ];
  };
}
