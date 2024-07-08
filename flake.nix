{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
    authentik-nix.url = "github:nix-community/authentik-nix/node-22";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    flake-parts.url = "github:hercules-ci/flake-parts";
    ez-configs.url = "github:ehllie/ez-configs";
    nixos-tests.url = "github:esselius/nixos-tests";
    devshell.url = "github:numtide/devshell";

    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        inputs.ez-configs.flakeModule
        inputs.nixos-tests.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };

        darwin.hosts.Fox.userHomeModules = [ "peteresselius" ];
        darwin.hosts.Petere-MBP.userHomeModules = [ "peteresselius" ];
        nixos.hosts.adama.userHomeModules = [ "peteresselius" ];
      };
      perSystem = { system, pkgs, config, lib, specialArgs, options }: {
        devshells.default = {
          env = [{
            name = "PLAYWRIGHT_BROWSERS_PATH";
            value = pkgs.playwright-driver.browsers;
          }];
        };

        nixosTests = {
          path = ./tests;
          args = {
            inherit inputs;
            myModules = self.nixosModules;
          };
        };
      };
    };
}
