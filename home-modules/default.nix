{ ezModules, osConfig, pkgs, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
  ];

  home = {
    stateVersion = "24.05";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/peteresselius" else "/home/peteresselius";
    username = "peteresselius";
  };

  context = osConfig.context;
}
