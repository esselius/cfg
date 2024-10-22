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
}
