{ lib, pkgs, config, ... }:

let
  cfg = config.profiles.tools;
  inherit (lib) mkMerge mkIf;
in
{
  options.profiles.tools = {
    k8s = lib.mkEnableOption "Install k8s packages & set shell config";
    minio = lib.mkEnableOption "Install minio packages";
  };

  config = mkMerge [
    (mkIf cfg.k8s {
      programs = {
        fish = {
          shellAbbrs = {
            k = "kubectl";
            kcuc = "kubectl config use-context";
            kccc = "kubectl config current-context";
          };
        };
      };

      home.packages = with pkgs; [
        k9s
        krew
        minio-client
        sqlfluff
        stern
      ];
    })

    (mkIf cfg.minio {
      home.packages = with pkgs; [
        minio-client
      ];
    })
  ];
}
