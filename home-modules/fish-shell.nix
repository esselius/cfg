{ pkgs, ... }:

{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      '';
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        gcloud.disabled = true;
        scala.disabled = true;
        python.disabled = true;
        git_status.disabled = true;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
