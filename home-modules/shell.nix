{ pkgs, ... }:

{
  programs = {
    fish = {
      enable = true;

      shellAliases = {
        gcb = "git checkout -b";
        gs = "git status -sb";
        "gcan!" = "git commit -v -a --no-edit --amend";
        gcam = "git commit -a -m";
        gl = "git pull";
        gp = "git push";
        gpsup = "git push --set-upstream origin (git rev-parse --abbrev-ref HEAD)";
        gpf = "git push --force-with-lease";
      };

      shellAbbrs = {
        gco = "git checkout";

        k = "kubectl";
        kcuc = "kubectl config use-context";
        kccc = "kubectl config current-context";

        rg = "rg -S --hidden --glob '!.git/*'";
      };
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings.gcloud.disabled = true;
    };

    ripgrep.enable = true;
  };

  home.packages = with pkgs; [
    nixpkgs-fmt
    jq
  ];
}
