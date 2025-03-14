{ inputs, ... }:

{
  imports = [
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
  ];

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

    raspberry-pi.config.all.base-dt-params.krnbt = {
      enable = true;
      value = "on";
    };
  };
}
