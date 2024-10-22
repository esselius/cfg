{ inputs, ... }:

{
  nix = {
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';

    settings.trusted-users = [ "root" "@wheel" ];

    registry.nixpkgs.flake = inputs.nixpkgs;

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
  };
}
