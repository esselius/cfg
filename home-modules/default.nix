{ ezModules, osConfig, pkgs, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
    ezModules.terminal
    ezModules.nix
  ];

  inherit (osConfig) context;
  inherit (osConfig) formfactor;
}
