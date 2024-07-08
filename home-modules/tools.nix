{ pkgs, ... }:

{
  programs = {
    fish = {
      shellAbbrs = {
        k = "kubectl";
        kcuc = "kubectl config use-context";
        kccc = "kubectl config current-context";

        rg = "rg -S --hidden --glob '!.git/*'";
      };
    };

    ripgrep.enable = true;
  };

  home.packages = with pkgs; [
    nixpkgs-fmt
    jq
    zstd
    nixos-rebuild
  ];
}
