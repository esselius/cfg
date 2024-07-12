{ ezModules, ... }:

{
  imports = [
    ezModules.user-peteresselius
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.05";

  context = "home";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.wireless.enable = true;
  networking.wireless.userControlled.enable = true;

  time.timeZone = "Europe/Stockholm";

  networking.useDHCP = true;

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [{
    device = "/dev/disk/by-label/swap";
  }];
}
