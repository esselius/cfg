{ ezModules, config, lib, ... }:

let
  inherit (lib) mkMerge mkIf;
in
{
  imports = [
    ezModules.fish-shell
    ezModules.git
    ezModules.ssh
    ezModules.profiles
  ];

  config = mkMerge [
    {
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      age.secrets.email.file = ../secrets/${config.context}-email.age;
      programs.fish.shellInit = ''
        set -x EMAIL (cat ${config.age.secrets.email.path})
      '';
    }

    (mkIf (config.context == "home") { })

    (mkIf (config.context == "work") {
      profiles.tools = {
        asdf = true;
        k8s = true;
        minio = true;
        task = true;
      };

      programs.fish.shellInit = ''
        set -x DBT_USER (cat ${config.age.secrets.email.path})
      '';
    })
  ];
}
