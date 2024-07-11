{ ezModules, ... }:

{
  imports = [
    ezModules.user-peteresselius
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.05";

  context = "home";
}
