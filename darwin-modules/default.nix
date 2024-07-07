{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.linux-builder
    ezModules.nix-multi-user
    ezModules.shell
    ezModules.flakes
  ];
}