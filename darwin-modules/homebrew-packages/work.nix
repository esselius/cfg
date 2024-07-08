{ lib, config, ... }:

{
  homebrew = {
    casks = lib.mkIf (config.context == "work") [
      "cyberduck"
      "datagrip"
      "docker"
      "goland"
      "google-cloud-sdk"
      "intellij-idea"
      "intune-company-portal"
      "microsoft-teams"
      "tunnelblick"
    ];

    brews = lib.mkIf (config.context == "work") [
      "azure-cli"
    ];
  };
}
