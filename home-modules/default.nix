{ osConfig, config, pkgs, ... }:

{
  inherit (osConfig) context formfactor mainUser;

  home = {
    stateVersion = "24.05";
    homeDirectory = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + config.mainUser;
    username = config.mainUser;
  };
}
