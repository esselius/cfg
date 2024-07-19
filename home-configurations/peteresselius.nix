{ ezModules, config, lib, ... }:

let
  inherit (lib) mkMerge mkIf;
in
{
  imports = [
    ezModules.asdf
    ezModules.fish-shell
    ezModules.git
    ezModules.ssh
    ezModules.profiles
  ];

  config = mkMerge [
    {
      age.secrets.email.file = ../secrets/${config.context}-email.age;
      programs.fish.shellInit = ''
        set -x EMAIL (cat ${config.age.secrets.email.path})
      '';
    }

    (mkIf (config.context == "home") {

    })

    (mkIf (config.context == "work") {
      profiles.tools = {
        k8s = true;
        minio = true;
      };

      programs.fish.shellInit = ''
        set -x DBT_USER (cat ${config.age.secrets.email.path})
      '';
    })
  ];
}
