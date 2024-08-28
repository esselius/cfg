{ inputs, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.nix_2_23;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
      use-case-hack = false
    '';

    settings.trusted-users = [ "@admin" ];

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      interval = { Hour = 3; Minute = 15; Weekday = 6; };
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs-darwin;
      nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
    };

    nixPath = lib.mkForce [
      "nixpkgs=${inputs.nixpkgs-darwin}"
      "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    ];
  };

  services.nix-daemon.enable = true;

  system.stateVersion = 4;
}
