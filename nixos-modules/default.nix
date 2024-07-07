{ ezModules, ... }:

{
  imports = [
    ezModules.context
  ];

  nix.settings.trusted-users = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}
