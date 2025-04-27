{ config, ... }:

{
  nix-homebrew = {
    enable = true;
    user = config.mainUser;
  };
  homebrew.enable = true;

  imports = [
    ./common.nix
    ./home.nix
    ./work.nix
  ];
}
