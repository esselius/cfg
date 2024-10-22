{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
    ezModules.nix
    ../overlays.nix
  ];
}
