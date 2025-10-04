{ config, ... }:

{
  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
  };
  homebrew.enable = true;

  imports = [
    ./common.nix
  ];
}
