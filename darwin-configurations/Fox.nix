{ inputs, ezModules, ... }:

{
  imports = [
    ezModules.tiling-wm
    ezModules.homebrew-packages
    ezModules.linux-builder
    ezModules.nixpkgs-path
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  context = "home";
  formfactor = "desktop";
  mainUser = "peteresselius";

  system.stateVersion = 4;
}
