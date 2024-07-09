{ inputs, pkgs, ... }:
let
  unstable-pkgs = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
  inherit (unstable-pkgs.darwin) linux-builder;
in
{
  nix.linux-builder = {
    enable = true;
    package = linux-builder;
    maxJobs = 4;
    ephemeral = true;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 100 * 1024;
          memorySize = 16 * 1024;
        };
        cores = 8;
      };
    };
  };
}
