{ inputs, ezModules, config, ... }:

{
  imports = [
    ezModules.context
    ezModules.terminal
    ezModules.nix
    ezModules.neovim
    ezModules.fish-shell
    ezModules.git
    ezModules.ssh
    ezModules.profiles
    inputs.agenix.homeManagerModules.default
    inputs.krewfile.homeManagerModules.krewfile
    inputs.nix-index-database.hmModules.nix-index
    inputs.nixvim.homeManagerModules.nixvim
  ];

  config = {
    age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    age.secrets.email.file = ../secrets/${config.context}-email.age;
    programs.fish.shellInit = ''
      set -x EMAIL (sh -c 'cat ${config.age.secrets.email.path}')
    '';
    context = "home";
  };
}
