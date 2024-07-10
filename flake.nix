{
  nixConfig = {
    extra-substituters = "https://esselius.cachix.org";
    extra-trusted-public-keys = "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
    authentik-nix.url = "github:nix-community/authentik-nix/node-22";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    flake-parts.url = "github:hercules-ci/flake-parts";
    ez-configs.url = "github:ehllie/ez-configs";
    nixos-tests.url = "github:esselius/nixos-tests";

    agenix.url = "github:ryantm/agenix";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
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
      perSystem = { pkgs, ... }: {
        nixosTests = {
          path = ./tests;
          args = {
            inherit inputs;
            myModules = self.nixosModules;
          };
          env = {
            PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
          };
        };
      };
    };
}
