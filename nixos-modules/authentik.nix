{ inputs, ... }:

{
  _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;

  imports = [
    inputs.authentik-nix.nixosModules.default
  ];
}
