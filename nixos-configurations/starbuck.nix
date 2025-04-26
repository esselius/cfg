{ ezModules, ... }:

{
  imports = [
    ezModules.sshd
    ezModules.user-peteresselius
    ezModules.nix-gc
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "home";
  formfactor = "server";

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
