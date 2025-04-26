{ lib, config, ... }:

{
  homebrew = {
    casks = lib.mkIf (config.context == "work") [
      "cyberduck"
      "datagrip"
      "docker"
      "google-cloud-sdk"
      "intellij-idea"
      "microsoft-teams"
      "microsoft-office"
      "postman"
      "wireshark"
    ];

    brews = lib.mkIf (config.context == "work") [
      "azure-cli"
      "protobuf"
    ];
  };
}
