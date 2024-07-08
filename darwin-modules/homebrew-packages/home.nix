{ lib, config, ... }:

{
  homebrew = {
    casks = lib.mkIf (config.context == "home") [
      "intellij-idea-ce"
      "plex-media-server"
      "qgis"
      "screens-connect"
      "steam"
      "transmission"
    ];
  };
}
