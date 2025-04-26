{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
    ezModules.nix
    ezModules.profiles
    ../overlays.nix
  ];
}
