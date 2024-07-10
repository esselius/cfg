{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.profiles
    ezModules.agenix
  ];

  nix.settings.trusted-users = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}
