{ modulesPath, ezModules, ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "work";
  formfactor = "vm";

  imports = [
    ezModules.hardware-vm
    ezModules.sshd
    ezModules.user-peteresselius
    ezModules.sysdig
  ];

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;
}
