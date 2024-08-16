{ inputs, pkgs, ... }:

{
  imports = [ inputs.agenix.homeManagerModules.default ];

  home.packages = [ inputs.agenix.packages.${pkgs.system}.default ];
}
