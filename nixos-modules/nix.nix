{ inputs, ... }:

{
  nix = {
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';

    settings.trusted-users = [ "root" "@wheel" ];

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    registry.nixpkgs.flake = inputs.nixpkgs;

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
  };
}
