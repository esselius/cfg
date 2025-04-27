{
  imports = [
    ../nixos-modules/sshd.nix
    ../nixos-modules/user-peteresselius.nix
    ../nixos-modules/nix-gc.nix
    ../nixos-modules/hardware-rpi5.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "home";
  formfactor = "server";
  mainUser = "peteresselius";

  profiles.telemetry.enable = true;

  networking.firewall.allowedTCPPorts = [
    9090
  ];

  hardware-rpi5 = {
    enable = true;
    enableNVMe = true;
    enablePCIeGen3 = true;
    enableMaxUSBCurrent = true;
  };
}
