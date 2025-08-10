{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types) path;
in
{
  options = {
    nixpkgs-path = mkOption {
      type = path;
    };
    nixpkgs-unstable-path = mkOption {
      type = path;
    };
  };
}
