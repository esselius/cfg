{
  programs = {
    fish.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings.gcloud.disabled = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
