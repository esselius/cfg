{ pkgs, lib, ... }:

{
  programs = {
    ssh = {
      enable = true;
      extraConfig = lib.mkIf pkgs.hostPlatform.isDarwin ''
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      '';
    };
  };
}