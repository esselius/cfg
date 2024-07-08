{ ezModules, ... }:

{
  imports = [
    ezModules.user-peteresselius
    ezModules.desktop
    ezModules.case-sensitive-nix-store
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  context = "work";
}
