{ config, lib, ... }:

let
  cfg = config.profiles.ingress;
  inherit (lib) types mkOption mkEnableOption mkIf concatMapAttrs;
in
{
  options = {
    profiles.ingress = {
      enable = mkEnableOption "ingress";
    };
  };

  config = mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;

        statusPage = true;

        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;

        virtualHosts._.default = true;
      };
    };
  };
}
