{ ezModules, ... }:

{
  imports = [
    ezModules.context
    ezModules.linux-builder
    ezModules.nix-multi-user
    ezModules.case-sensitive-nix-store
  ];

  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes
  '';
}
