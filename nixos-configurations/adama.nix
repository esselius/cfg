{ inputs, ezModules, config, ... }:

{
  imports = [
    ezModules.hardware-rpi5
    ezModules.sshd
    ezModules.user-peteresselius
    ezModules.auth
    ezModules.secrets
    inputs.authentik-nix.nixosModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "home";

  age.secrets.authentik-env.file = ../secrets/authentik-env.age;
  _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;
  auth = {
    enable = true;
    env-file = config.age.secrets.authentik-env.path;
  };
}
