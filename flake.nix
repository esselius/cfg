{
  nixConfig = {
    extra-substituters = [
      "https://esselius.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    dev = {
      url = "github:esselius/dev";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin-25-05.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-darwin-26-05.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # nix-darwin-25-05.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    nix-darwin-25-05.url = "github:esselius/nix-darwin/linux-builder-with-determinate-nix-25-05";
    nix-darwin-25-05.inputs.nixpkgs.follows = "nixpkgs-darwin-25-05";
    nix-darwin-26-05.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin-26-05.inputs.nixpkgs.follows = "nixpkgs-darwin-26-05";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    home-manager-darwin-25-05.url = "github:nix-community/home-manager/release-25.05";
    home-manager-darwin-25-05.inputs.nixpkgs.follows = "nixpkgs-darwin-25-05";
    home-manager-darwin-26-05.url = "github:nix-community/home-manager/release-26.05";
    home-manager-darwin-26-05.inputs.nixpkgs.follows = "nixpkgs-darwin-26-05";

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    krewfile.url = "github:brumhard/krewfile";
    krewfile.inputs.nixpkgs.follows = "nixpkgs-darwin-26-05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-darwin-26-05";
        home-manager.follows = "home-manager-darwin-26-05";
        darwin.follows = "nix-darwin-26-05";
      };
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin-25-05";
    };

    # microvm = {
    #   url = "github:esselius/microvm.nix/darwin-v2";
    #   inputs.spectrum.follows = "dev";
    # };

    easy-hosts.url = "github:tgirlcloud/easy-hosts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.dev.flakeModule
        inputs.easy-hosts.flakeModule
      ];

      systems = [
        "aarch64-linux"
        "aarch64-darwin"
      ];

      flake.homeConfigurations =
        let
          common = [
            ./home-modules/default.nix
            ./home-modules/fish-shell.nix
            ./home-modules/git.nix
            ./home-modules/context.nix
            ./home-modules/terminal.nix
            ./home-modules/nix.nix
            ./home-modules/neovim.nix
            ./home-modules/profiles
            ./home-modules/ssh.nix
            ./home-modules/git.nix

            ./overlays.nix

            inputs.agenix.homeManagerModules.default
            inputs.nix-index-database.homeModules.nix-index
            inputs.nixvim.homeModules.nixvim
            inputs.krewfile.homeManagerModules.krewfile

            (
              { pkgs, ... }:
              {
                nix.package = pkgs.nix; # Standalone home-manager requires an explicit nix package
                nixpkgs.config = {
                  allowUnfree = true;
                };
              }
            )
          ];
        in
        {
          WorkUser = inputs.home-manager-darwin-25-05.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs-darwin-25-05.legacyPackages.aarch64-darwin;
            extraSpecialArgs = { inherit inputs; };
            modules = common ++ [
              {
                formfactor = "laptop";
                mainUser = "pepp";
                home.stateVersion = "24.05";

                programs.mise = {
                  enable = true;
                  enableFishIntegration = true;
                };

                profiles.tools = {
                  k8s = true;
                  minio = true;
                  task = true;
                  trino = true;
                  google-cloud = true;
                };
              }
            ];
          };
        };

      easy-hosts = {
        perClass = _: {
          modules = [
            ./darwin-modules/tiling-wm.nix
            ./darwin-modules/linux-builder.nix
            ./darwin-modules/security.nix
            ./darwin-modules/homebrew-packages
            ./darwin-modules/user.nix

            ./overlays.nix

            inputs.nix-homebrew.darwinModules.nix-homebrew
          ];
        };

        hosts = {
          WorkLaptop = {
            arch = "aarch64";
            class = "darwin";
            nixpkgs = inputs.nixpkgs-darwin-26-05;
            nix-darwin = inputs.nix-darwin-26-05;
            modules = [
              inputs.determinate.darwinModules.default
              {
                system.primaryUser = "pepp";
                system.stateVersion = 5;

                determinateNix.customSettings = {
                  trusted-users = [
                    "root"
                    "pepp"
                  ];
                  extra-substituters = [
                    "https://esselius.cachix.org"
                    "https://nix-community.cachix.org"
                    "https://devenv.cachix.org"
                  ];
                  extra-trusted-public-keys = [
                    "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA="
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
                  ];
                };
              }

              ./darwin-modules/homebrew-packages/work.nix
            ];
            specialArgs = { inherit inputs; };
          };
        };
      };

      dev.enable = true;
    };
}
