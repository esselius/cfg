{ modulesPath, ezModules, ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "work";
  formfactor = "vm";

  imports = [
    "${modulesPath}/virtualisation/vmware-guest.nix"
    ezModules.hardware-vm
    ezModules.user-peteresselius
  ];
}
