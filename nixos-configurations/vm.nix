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

  programs.nix-ld.enable = true;
  nix.settings.extra-sandbox-paths = [ "/lib" ];
  boot.binfmt.emulatedSystems = ["x86_64-linux"];
  nix.settings.sandbox = "relaxed";

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;
}
