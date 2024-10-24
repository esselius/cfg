{
  programs = {
    fish.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings.gcloud.disabled = true;
      settings.scala.disabled = true;
      settings.python.disabled = true;
      settings.git_status.disabled = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
