{ config, ... }:

{
  nix = {
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';

    settings.trusted-users = [ "root" "@wheel" ];

    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };

    nixPath = [
      "nixpkgs=${config.nixpkgs-path}"
      "nixpkgs-unstable=${config.nixpkgs-unstable-path}"
    ];
  };
}
