{ lib, config, ... }:

{
  homebrew = {
    casks = lib.mkIf (config.context == "work") [
      "cyberduck"
      "datagrip"
      "intellij-idea"
      "microsoft-teams"
      "microsoft-office"
      "postman"
      "utm"
    ];

    brews = lib.mkIf (config.context == "work") [
      "azure-cli"
      "protobuf"
    ];
  };
}
