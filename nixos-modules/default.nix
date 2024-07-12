{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
  ];

  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes
  '';

  nix.settings.trusted-users = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}
