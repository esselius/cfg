{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.linux-builder
    ezModules.nix
    ezModules.security
  ];
}
