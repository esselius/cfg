{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types) enum str path anything;
in
{
  options = {
    context = mkOption {
      type = enum [ "home" "work" ];
    };
    formfactor = mkOption {
      type = enum [ "desktop" "laptop" "server" "vm" ];
    };
    mainUser = mkOption {
      type = str;
    };
    nixpkgs-path = mkOption {
      type = path;
    };
    nixpkgs-unstable-path = mkOption {
      type = path;
    };
    pyproject-nix-lib = mkOption {
      type = anything;
      default = null;
    };
  };
}
