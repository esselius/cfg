{ ezModules, config, ... }:

{
  imports = [
    ezModules.shell
    ezModules.ssh
    ezModules.git
    ezModules.secrets
    ezModules.asdf
  ];

  home.stateVersion = "24.05";

  programs.git.userName = "Peter Esselius";

  age.secrets.email.file = ../secrets/${config.context}-email.age;
  programs.fish.shellInit = ''
    set -x EMAIL (cat ${config.age.secrets.email.path})
    set -x DBT_USER (cat ${config.age.secrets.email.path})
  '';
  # age.secrets.github-token.file = ../secrets/github-token.age;
  # nix.extraOptions = ''
  #   !include ${config.age.secrets.github-token.path}
  # '';
}
