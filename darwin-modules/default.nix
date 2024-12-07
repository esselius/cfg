{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.nix
    ezModules.security
    ../overlays.nix
  ];
}
