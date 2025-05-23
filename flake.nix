{
  nixConfig = {
    extra-substituters = "https://esselius.cachix.org";
    extra-trusted-public-keys = "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA=";
  };

  inputs = {
    dev = {
      url = "github:esselius/dev";
      inputs.agenix-rekey.url = "github:esselius/agenix-rekey/fixes";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix-rekey.follows = "dev/agenix-rekey";

    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.follows = "nixpkgs-unstable";
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-24.11";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs-nixos";
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

    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
    pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";
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
              nixpkgs-unstable-path = inputs.nixpkgs-unstable;
            }
            inputs.home-manager.darwinModules.home-manager
            ({ config, ... }: {
              home-manager.users.${config.mainUser} = {
                imports = [
                  ./home-configurations/peteresselius.nix
                  ./home-modules/default.nix
                  inputs.agenix.homeManagerModules.default
                  inputs.krewfile.homeManagerModules.krewfile
                  inputs.nix-index-database.hmModules.nix-index
                  inputs.nixvim.homeManagerModules.nixvim
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

        nixosConfigurations.adama = inputs.nixpkgs-nixos.lib.nixosSystem {
          modules = [
            ./nixos-configurations/adama.nix
            ./nixos-modules/default.nix
            inputs.raspberry-pi-nix.nixosModules.raspberry-pi
            inputs.agenix.nixosModules.default
            inputs.agenix-rekey.nixosModules.default
            inputs.authentik-nix.nixosModules.default
            {
              _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;
              nixpkgs-path = inputs.nixpkgs-nixos;
              nixpkgs-unstable-path = inputs.nixpkgs-unstable;

              age.rekey = {
                hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfILv+PA582KwZYcJRX2yCcQVBlh7T9uWUieLBFXHo/";
                masterIdentities = [
                  { identity = "/Users/peteresselius/.age-plugin-se.key"; pubkey = "age1se1qw3jfq82crjk5x36g7wr8pxscvlynwaxpqjt6wran7j23ped4gjsypanfet"; }
                  { identity = "/Users/pepp/.age-plugin-se.key"; pubkey = "age1se1qgqzwsmme3yatp3ezp4nfncxytdp4mawpguxm2ll08dpw29sp7dxs2ls372"; }
                ];
                storageMode = "local";
                localStorageDir = ./. + "/secrets/rekeyed/adama";
              };

              fileSystems = {
                "/" = {
                  device = "/dev/disk/by-label/NIXOS_SD";
                  fsType = "ext4";
                };
                "/boot/firmware" = {
                  device = "/dev/disk/by-label/FIRMWARE";
                  fsType = "vfat";
                };
              };

              pyproject-nix-lib = inputs.pyproject-nix.lib;
            }
            inputs.home-manager-nixos.nixosModules.home-manager
            ({ config, ... }: {
              home-manager.users.${config.mainUser} = {
                imports = [
                  ./home-configurations/peteresselius.nix
                  ./home-modules/default.nix
                  inputs.agenix.homeManagerModules.default
                  inputs.krewfile.homeManagerModules.krewfile
                  inputs.nix-index-database.hmModules.nix-index
                  inputs.nixvim.homeManagerModules.nixvim
                ];
              };
              home-manager.extraSpecialArgs = { inherit inputs; };
            })
          ];
          specialArgs = { inherit inputs; };
        };
        nixosConfigurations.starbuck = inputs.nixpkgs-nixos.lib.nixosSystem {
          modules = [
            ./nixos-configurations/starbuck.nix
            ./nixos-modules/default.nix
            inputs.raspberry-pi-nix.nixosModules.raspberry-pi
            inputs.agenix.nixosModules.default
            inputs.agenix-rekey.nixosModules.default
            inputs.authentik-nix.nixosModules.default
            {
              nixpkgs-path = inputs.nixpkgs-nixos;
              nixpkgs-unstable-path = inputs.nixpkgs-unstable;
              age.rekey = {
                hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFi1DoYv7wvIkYvTrjUVEqZI00H6d5437IgprVdFMI1+";
                masterIdentities = [
                  { identity = "/Users/peteresselius/.age-plugin-se.key"; pubkey = "age1se1qw3jfq82crjk5x36g7wr8pxscvlynwaxpqjt6wran7j23ped4gjsypanfet"; }
                  { identity = "/Users/pepp/.age-plugin-se.key"; pubkey = "age1se1qgqzwsmme3yatp3ezp4nfncxytdp4mawpguxm2ll08dpw29sp7dxs2ls372"; }
                ];
                storageMode = "local";
                localStorageDir = ./. + "/secrets/rekeyed/starbuck";
              };
              fileSystems = {
                "/" = {
                  device = "/dev/disk/by-label/NIXOS_SD";
                  fsType = "ext4";
                };
                "/boot/firmware" = {
                  device = "/dev/disk/by-label/FIRMWARE";
                  fsType = "vfat";
                };
              };
            }
            inputs.home-manager-nixos.nixosModules.home-manager
            ({ config, ... }: {
              home-manager.users.${config.mainUser} = {
                imports = [
                  ./home-configurations/peteresselius.nix
                  ./home-modules/default.nix
                  inputs.agenix.homeManagerModules.default
                  inputs.krewfile.homeManagerModules.krewfile
                  inputs.nix-index-database.hmModules.nix-index
                  inputs.nixvim.homeManagerModules.nixvim
                ];
              };
            })
          ];
        };
      };


      dev.enable = true;
    };
}
