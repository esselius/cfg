{ inputs, ... }:

{
  imports = [
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
  ];

  raspberry-pi-nix = {
    uboot.enable = false;
    pin-inputs.enable = true;
  };
}
