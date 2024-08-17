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
    deadnix
    direnv
    go-task
    home-manager
    jq
    nixos-rebuild
    nixpkgs-fmt
    socat
    statix
    step-ca
    step-cli
    watch
    yq
    zstd
    nil
  ];
}
