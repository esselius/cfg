{
  nixConfig = {
    extra-substituters = "https://esselius.cachix.org";
    extra-trusted-public-keys = "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-23-11.url = "github:NixOS/nixpkgs/nixos-23.11";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs-23-11";
    authentik-nix.url = "github:esselius/authentik-nix/patch-1";
    authentik-nix.inputs.nixpkgs.follows = "nixpkgs";
    authentik-nix.inputs.flake-parts.follows = "flake-parts";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.nix-darwin.follows = "nix-darwin";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs-darwin";

    flake-parts.url = "github:hercules-ci/flake-parts";
    ez-configs.url = "github:ehllie/ez-configs";
    ez-configs.inputs.nixpkgs.follows = "nixpkgs";
    ez-configs.inputs.flake-parts.follows = "flake-parts";
    nixos-tests.url = "github:esselius/nixos-tests";
    nixos-tests.inputs.flake-parts.follows = "flake-parts";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "nix-darwin";

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
