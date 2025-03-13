{ lib, config, pkgs, ... }:
let
  cfg = config.profiles.storage;
in
{
  options.profiles.storage = {
    enable = lib.mkEnableOption "Enable storage profile";
  };
  config = lib.mkIf cfg.enable {
    services.garage = {
      enable = true;
      package = pkgs.garage_1_1_0;
      settings = {
        metadata_dir = "/var/lib/garage/meta";
        data_dir = "/var/lib/garage/data";
        db_engine = "lmdb";
        replication_factor = 1;
        rpc_bind_addr = "[::]:3901";
        rpc_secret = "6c7397ea27a7fa2f15d1697f0803eff12ea6dff1c0b4788330f338ecc71b5290";
        s3_api = {
          s3_region = "garage";
          api_bind_addr = "[::]:3900";
          root_domain = ".s3.starbuck.lan";
        };
        s3_web = {
          bind_addr = "[::]:3902";
          root_domain = ".s3-web.starbuck.lan";
          index = "index.html";
        };
      };
    };
  };
}
