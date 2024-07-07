{ ezModules, ... }:

{
  imports = [
    ezModules.hardware-rpi5
    ezModules.sshd
    ezModules.user-peteresselius
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";
  
  context = "home";
}