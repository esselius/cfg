{ pkgs, ... }:

{
  users.users.peteresselius = {
    description = "Peter Esselius";
    home = "/Users/peteresselius";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMdasDSm/XlOpv15asMENnQ/E9W9rXExBcUAVd/G6Mo"
    ];
  };

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
}
