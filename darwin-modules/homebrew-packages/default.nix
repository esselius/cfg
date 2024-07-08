{ inputs, ... }:

{
  nix-homebrew = {
    enable = true;
    user = "peteresselius";
  };
  homebrew.enable = true;

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./common.nix
    ./home.nix
    ./work.nix
  ];
}
