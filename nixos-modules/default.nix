{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
    ezModules.nix
    ../overlays.nix
  ];

  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}
