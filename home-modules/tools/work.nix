{ lib, pkgs, config, ... }:

{
  programs = {
    fish = {
      shellAbbrs = {
        k = "kubectl";
        kcuc = "kubectl config use-context";
        kccc = "kubectl config current-context";
      };
    };
  };
  home.packages = lib.mkIf (config.context == "work") (with pkgs; [
    k9s
    krew
    minio-client
    stern
  ]);
}
