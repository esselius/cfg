{ ezModules, ... }:

{
  imports = [
    ezModules.tiling-wm
    ezModules.homebrew-packages
    ezModules.user-peteresselius
    ezModules.linux-builder
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  context = "home";
  formfactor = "desktop";
}
