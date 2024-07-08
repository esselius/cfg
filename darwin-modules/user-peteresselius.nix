{ pkgs, ... }:

{
  users.users.peteresselius = {
    description = "Peter Esselius";
    home = "/Users/peteresselius";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
}
