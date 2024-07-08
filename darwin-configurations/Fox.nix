{ ezModules, ... }:

{
  imports = [
    ezModules.user-peteresselius
    ezModules.desktop
    ezModules.case-sensitive-nix-store
    ezModules.homebrew
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  context = "home";
}
