{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];
  programs = {
    fish = {
      shellAbbrs = {
        rg = "rg -S --hidden --glob '!.git/*'";
      };
    };

    command-not-found.enable = false;
    nix-index-database.comma.enable = true;

    ripgrep.enable = true;
  };

  home.packages = with pkgs; [
    cachix
    cmatrix
    deadnix
    direnv
    jq
    nixos-rebuild
    nixpkgs-fmt
    socat
    watch
    zstd
    yq
    step-cli
    step-ca
  ];
}
