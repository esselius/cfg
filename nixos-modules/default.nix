{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.authentik
    ezModules.authentik-blueprints
    ezModules.agenix
  ];

  nix.settings.trusted-users = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}
