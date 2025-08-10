{ config
, pkgs
, ...
}:

{

  home = {
    homeDirectory = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + config.mainUser;
    username = config.mainUser;
  };
}
