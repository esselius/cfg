{ inputs, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    extraOptions = ''
      extra-experimental-features = nix-command flakes
      use-case-hack = false
    '';

    settings = {
      trusted-users = [ "@admin" ];
      substituters = [
        "https://esselius.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      plugin-files = "${pkgs.nix-plugins}/lib/nix/plugins";
      extra-builtins-file = "${../extra-builtins.nix}";
    };

    optimise = {
      automatic = true;
      interval = [{ Weekday = 7; Hour = 4; Minute = 15; }];
    };

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
