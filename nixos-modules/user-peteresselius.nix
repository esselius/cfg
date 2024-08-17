{ pkgs, ... }:

{
  users.users.peteresselius = {
    isNormalUser = true;
    description = "Peter Esselius";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMdasDSm/XlOpv15asMENnQ/E9W9rXExBcUAVd/G6Mo"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSArp+2Vu/AgbaiFYRLH/gtENAqwd6/aPVwgX429Tk+"
    ];
    hashedPassword = "$y$j9T$E9zqN0.bUa0F8DlygXLw61$7zSyujQLTey76rr.BzD4LVRzGXXP9gKTUmP.iOkXxfA";
  };

  programs.fish.enable = true;
}
