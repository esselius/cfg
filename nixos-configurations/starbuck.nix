{ ezModules, ... }:

{
  imports = [
    ezModules.hardware-rpi5
    ezModules.sshd
    ezModules.user-peteresselius
    ezModules.nix-gc
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "home";
  formfactor = "server";

  networking.firewall.allowedTCPPorts = [
    9100
  ];

  profiles.storage.enable = true;
  profiles.telemetry.enable = true;
}
