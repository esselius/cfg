{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
    ezModules.nix
  ];

  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}
