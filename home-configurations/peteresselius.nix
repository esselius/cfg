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
    context = "home";
  };
}
