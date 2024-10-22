{ ezModules, osConfig, pkgs, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
    ezModules.terminal
    ezModules.nix
    ezModules.neovim
  ];

  inherit (osConfig) context;
  inherit (osConfig) formfactor;
}
