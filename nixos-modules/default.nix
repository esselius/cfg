{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.authentik
    ezModules.agenix
  ];

  nix.settings.trusted-users = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}
