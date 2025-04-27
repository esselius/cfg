{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.nix
    ezModules.security
    ezModules.user
    ../overlays.nix
  ];
}
