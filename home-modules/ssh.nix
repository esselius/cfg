{ pkgs
, lib
, options
, ...
}:

let
  identityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
in
{
  programs.ssh = {
    enable = true;
  }
  # home-manager 25.11+ replaced extraConfig and its implicit "Host *" defaults with programs.ssh.settings;
  # the dropped defaults all match OpenSSH's built-in ones
  // (
    if options.programs.ssh ? settings then
      {
        enableDefaultConfig = false;
        settings."*" = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          IdentityAgent = identityAgent;
        };
      }
    else
      {
        extraConfig = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
          IdentityAgent ${identityAgent}
        '';
      }
  );
}
