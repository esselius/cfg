{ ezModules, config, ... }:

{
  imports = [
    ezModules.shell
    ezModules.ssh
    ezModules.git
    ezModules.secrets
  ];

  home.stateVersion = "24.05";

  programs.git.userName = "Peter Esselius";

  age.secrets.email.file = ../secrets/${config.context}-email.age;
  programs.fish.shellInit = ''
    set -x EMAIL (cat ${config.age.secrets.email.path})
  '';
}