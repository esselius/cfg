{
  nixConfig = {
    extra-substituters = "https://esselius.cachix.org";
    extra-trusted-public-keys = "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA=";
  };

  inputs = {
    dev.url = "github:esselius/dev";
    dev.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.follows = "nixpkgs-unstable";
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-24.11";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix/v0.4.1";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs";
    authentik-nix = {
      url = "github:nix-community/authentik-nix/version/2025.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-nixos.url = "github:nix-community/home-manager/release-24.11";
    home-manager-nixos.inputs.nixpkgs.follows = "nixpkgs-nixos";

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    krewfile.url = "github:brumhard/krewfile";
    krewfile.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        darwin.follows = "nix-darwin";
      };
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = { url = "github:nix-community/nixvim"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.dev.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      flake = {
        darwinConfigurations.Fox = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin-modules/default.nix
            ./darwin-modules/tiling-wm.nix
            ./darwin-modules/homebrew-packages
            ./darwin-modules/linux-builder.nix
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nixpkgs.hostPlatform = "aarch64-darwin";

              context = "home";
              formfactor = "desktop";
              mainUser = "peteresselius";

              system.stateVersion = 4;
              nixpkgs-path = inputs.nixpkgs;
            }
            inputs.home-manager.darwinModules.home-manager
            ({ config, ... }: {
              home-manager.users.${config.mainUser} = {
                imports = [
                  ./home-configurations/peteresselius.nix
                  ./home-modules/default.nix
                ];
              };
              home-manager.extraSpecialArgs = { inherit inputs; };
            })
          ];
          specialArgs = { inherit inputs; };
        };

        darwinModules = {
          context = ./darwin-modules/context.nix;
          nix = ./darwin-modules/nix.nix;
          security = ./darwin-modules/security.nix;
          user = ./darwin-modules/user.nix;
          tiling-wm = ./darwin-modules/tiling-wm.nix;
          homebrew-packages = ./darwin-modules/homebrew-packages;
        };

        homeModules = {
          default = ./home-modules/default.nix;
          fish-shell = ./home-modules/fish-shell.nix;
          git = ./home-modules/git.nix;
          ssh = ./home-modules/ssh.nix;
          profiles = ./home-modules/profiles;
          context = ./home-modules/context.nix;
          terminal = ./home-modules/terminal.nix;
          nix = ./home-modules/nix.nix;
          neovim = ./home-modules/neovim.nix;
        };
      };

      dev.enable = true;
    };
}
