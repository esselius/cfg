{
  imports = [ ];

  boot = {
    initrd.availableKernelModules = [ "uhci_hcd" "ahci" "xhci_pci" "nvme" "usbhid" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
  swapDevices = [ ];

  virtualisation.vmware.guest.enable = true;

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

    "/boot" =
      {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };

    "host" = {
      fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
      device = ".host:/";
      options = [
        #      "umask=27"
        "uid=1000"
        "gid=1000"
        "allow_other"
        "auto_unmount"
        "defaults"
      ];
    };
  };
}
