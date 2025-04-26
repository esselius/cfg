{ lib, config, ... }:

{
  homebrew = {
    casks = lib.mkIf (config.context == "home") [
      "plex-media-server"
      "screens-connect"
      "steam"
      "transmission"
    ];
  };
}
