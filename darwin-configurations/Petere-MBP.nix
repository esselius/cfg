{ ezModules, ... }:

{
  imports = [
    ezModules.tiling-wm
    ezModules.homebrew
    ezModules.user-peteresselius
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  context = "work";
}
