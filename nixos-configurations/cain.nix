{ ezModules, ... }:

{
  imports = [
    ezModules.user-peteresselius
    ezModules.sshd
    ezModules.nix-gc
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.05";

  context = "home";
  formfactor = "laptop";
  mainUser = "peteresselius";

  time.timeZone = "Europe/Stockholm";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

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

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
}
