{ lib, pkgs, config, ... }:

{
  home.packages = lib.mkIf (config.context == "home") (with pkgs; [
    nickel
   ]);
}
