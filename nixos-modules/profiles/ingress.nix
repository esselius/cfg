{ config, lib, ... }:

let
  cfg = config.profiles.ingress;
  inherit (lib) types mkOption mkEnableOption mkIf concatMapAttrs;
in
{
  options = {
    profiles.ingress = {
      enable = mkEnableOption "ingress";
      port = mkOption {
        type = types.int;
        default = 80;
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;

        defaultHTTPListenPort = cfg.port;

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
