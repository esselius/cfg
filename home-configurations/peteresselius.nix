{ inputs, pkgs, ezModules, config, lib, ... }:

let
  inherit (lib) mkMerge mkIf;
in
{
  imports = [
    ezModules.fish-shell
    ezModules.git
    ezModules.ssh
    ezModules.profiles
#    inputs.cfg-work.homeModules.sbt
  ];

  config = mkMerge [
    {
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      age.secrets.email.file = ../secrets/${config.context}-email.age;
      programs.fish.shellInit = ''
        set -x EMAIL (sh -c 'cat ${config.age.secrets.email.path}')
      '';

      home = {
        stateVersion = "24.05";
        homeDirectory = if pkgs.stdenv.isDarwin then "/Users/peteresselius" else "/home/peteresselius";
        username = "peteresselius";
      };
    }

    (mkIf (config.context == "home") { })

    (mkIf (config.context == "work") {
      programs.mise = {
        enable = true;
        enableFishIntegration = true;
      };
      profiles.tools = {
        # asdf = true;
        k8s = true;
        minio = true;
        task = true;
        trino = true;
        google-cloud = true;
      };

      programs.fish.shellInit = ''
        set -x DBT_USER (sh -c 'cat ${config.age.secrets.email.path}')
      '';
    })
  ];
}
