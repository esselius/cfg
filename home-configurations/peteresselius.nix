{ config, ... }:

{
  imports = [
    ../home-modules/context.nix
    ../home-modules/terminal.nix
    ../home-modules/nix.nix
    ../home-modules/neovim.nix
    ../home-modules/fish-shell.nix
    ../home-modules/git.nix
    ../home-modules/ssh.nix
    ../home-modules/profiles
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
