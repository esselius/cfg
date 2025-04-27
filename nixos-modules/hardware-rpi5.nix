{ lib, config, ... }:

let
  cfg = config.hardware-rpi5;
in
{
  options.hardware-rpi5 = {
    enable = lib.mkEnableOption "Enable extra Raspberry Pi 5 hardware features";
    enableNVMe = lib.mkEnableOption "Enable NVMe support";
    enablePCIeGen3 = lib.mkEnableOption "Enable PCIe Gen3 support";
    enableMaxUSBCurrent = lib.mkEnableOption "Enable maximum USB current";
  };

  config = lib.mkIf cfg.enable {
    raspberry-pi-nix = {
      uboot.enable = false;
      pin-inputs.enable = true;
      board = "bcm2712";
      libcamera-overlay.enable = false;
    };

    hardware = {
      bluetooth = {
        enable = true;
        settings.General.Experimental = true;
      };

      raspberry-pi.config.all = {
        options.usb_max_current_enable = lib.mkIf cfg.enableMaxUSBCurrent {
          enable = true;
          value = 1;
        };

        base-dt-params = {
          krnbt = {
            enable = true;
            value = "on";
          };

          nvme = lib.mkIf cfg.enableNVMe {
            enable = true;
          };

          pciex1_1 = lib.mkIf cfg.enablePCIeGen3 {
            enable = true;
            value = "gen3";
          };
        };
      };
    };
  };
}
