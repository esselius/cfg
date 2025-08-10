{ config, pkgs, ... }:

{
  users.users.${config.system.primaryUser} = {
    uid = 501;
    description = "Peter Esselius";
    home = "/Users/" + config.system.primaryUser;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMdasDSm/XlOpv15asMENnQ/E9W9rXExBcUAVd/G6Mo"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSArp+2Vu/AgbaiFYRLH/gtENAqwd6/aPVwgX429Tk+"
    ];
  };

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  users.knownUsers = [ config.system.primaryUser ];
}
