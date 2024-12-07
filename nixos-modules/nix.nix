{ inputs, pkgs, ... }:

{
  nix = {
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';

    settings.trusted-users = [ "root" "@wheel" ];

    registry.nixpkgs.flake = inputs.nixpkgs;

    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    ];
  };
}
