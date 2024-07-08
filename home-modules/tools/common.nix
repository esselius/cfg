{ pkgs, ... }:

{
  programs = {
    fish = {
      shellAbbrs = {
        rg = "rg -S --hidden --glob '!.git/*'";
      };
    };

    ripgrep.enable = true;
  };

  home.packages = with pkgs; [
    cmatrix
    jq
    nixos-rebuild
    nixpkgs-fmt
    socat
    watch
    zstd
  ];
}
