{
  nixConfig = {
    extra-substituters = "https://esselius.cachix.org";
    extra-trusted-public-keys = "esselius.cachix.org-1:h6FQzpdflxdZfnnL0caV88xt5K5sNzgO0VIHQthTymA=";
  };

  inputs = {
    dev = {
      url = "github:esselius/dev";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agenix-rekey.follows = "dev/agenix-rekey";

    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin-25-05.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-nixos-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-nixos-25-05.url = "github:NixOS/nixpkgs/nixos-25.05";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs-nixos-24-11";
    authentik-nix = {
      url = "github:nix-community/authentik-nix/version/2025.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # nix-darwin-25-05.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    nix-darwin-25-05.url = "github:esselius/nix-darwin/linux-builder-with-determinate-nix-25-05";
    nix-darwin-25-05.inputs.nixpkgs.follows = "nixpkgs-darwin-25-05";

    home-manager-nixos-24-11.url = "github:nix-community/home-manager/release-24.11";
    home-manager-nixos-24-11.inputs.nixpkgs.follows = "nixpkgs-nixos-24-11";
    home-manager-nixos-25-05.url = "github:nix-community/home-manager/release-25.05";
    home-manager-nixos-25-05.inputs.nixpkgs.follows = "nixpkgs-nixos-25-05";
    home-manager-darwin-25-05.url = "github:nix-community/home-manager/release-25.05";
    home-manager-darwin-25-05.inputs.nixpkgs.follows = "nixpkgs-darwin-25-05";

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    krewfile.url = "github:brumhard/krewfile";
    krewfile.inputs.nixpkgs.follows = "nixpkgs-darwin-25-05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-darwin-25-05";
        home-manager.follows = "home-manager-darwin-25-05";
        darwin.follows = "nix-darwin-25-05";
      };
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
    pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";

    microvm = {
      url = "github:esselius/microvm.nix/darwin-v2";
      inputs.nixpkgs.follows = "nixpkgs-nixos-25-05";
      inputs.spectrum.follows = "dev";
    };

    easy-hosts.url = "github:tgirlcloud/easy-hosts";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
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

            inputs.agenix.homeManagerModules.default
            inputs.nix-index-database.homeModules.nix-index
            inputs.nixvim.homeModules.nixvim
            inputs.krewfile.homeManagerModules.krewfile

            {
              nix.enable = false; # TODO nix.package not being set after using standalone HM
            }
          ];
        in
        {
          WorkUser = inputs.home-manager-darwin-25-05.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs-darwin-25-05.legacyPackages.aarch64-darwin;
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

          peteresselius = inputs.home-manager-darwin-25-05.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs-darwin-25-05.legacyPackages.aarch64-darwin;
            modules = common ++ [
              {
                context = "home";
                formfactor = "desktop";
                mainUser = "peteresselius";
                home.stateVersion = "24.05";
              }
            ];
          };
        };

      easy-hosts = {
        additionalClasses = {
          rpi = "nixos";
          vm = "nixos";
        };

        perClass = class: {
          modules =
            {
              darwin = [
                ./darwin-modules/tiling-wm.nix
                ./darwin-modules/linux-builder.nix
                ./darwin-modules/security.nix
                ./darwin-modules/homebrew-packages/common.nix
                ./darwin-modules/user.nix

                ./overlays.nix

                inputs.nix-homebrew.darwinModules.nix-homebrew
              ];
            }.${class};
        };

        hosts = {
          Fox = {
            arch = "aarch64";
            class = "darwin";
            nixpkgs = inputs.nixpkgs-darwin-25-05;
            nix-darwin = inputs.nix-darwin-25-05;
            modules = [
              ./darwin-modules/nix.nix

              {
                system.primaryUser = "peteresselius";
                system.stateVersion = 4;
              }

              ./darwin-modules/homebrew-packages/home.nix
            ];
            specialArgs = { inherit inputs; };
          };
          WorkLaptop = {
            arch = "aarch64";
            class = "darwin";
            nixpkgs = inputs.nixpkgs-darwin-25-05;
            nix-darwin = inputs.nix-darwin-25-05;
            modules = [
              {
                nix.enable = false; # Determinate Nix
                system.primaryUser = "pepp";
                system.stateVersion = 5;
              }

              ./darwin-modules/homebrew-packages/work.nix
            ];
            specialArgs = { inherit inputs; };
          };
          adama = {
            arch = "aarch64";
            class = "rpi";
            deployable = true;
            nixpkgs = inputs.nixpkgs-nixos-24-11;
            modules = [
              ./nixos-configurations/adama.nix
              ./nixos-modules/default.nix
              inputs.raspberry-pi-nix.nixosModules.raspberry-pi
              inputs.agenix.nixosModules.default
              inputs.agenix-rekey.nixosModules.default
              inputs.authentik-nix.nixosModules.default
              {
                _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;
                nixpkgs-path = inputs.nixpkgs-nixos-24-11;
                nixpkgs-unstable-path = inputs.nixpkgs-unstable;

                age.rekey = {
                  hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfILv+PA582KwZYcJRX2yCcQVBlh7T9uWUieLBFXHo/";
                  masterIdentities = [
                    {
                      identity = "/Users/peteresselius/.age-plugin-se.key";
                      pubkey = "age1se1qw3jfq82crjk5x36g7wr8pxscvlynwaxpqjt6wran7j23ped4gjsypanfet";
                    }
                    {
                      identity = "/Users/pepp/.age-plugin-se.key";
                      pubkey = "age1se1qgqzwsmme3yatp3ezp4nfncxytdp4mawpguxm2ll08dpw29sp7dxs2ls372";
                    }
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
              inputs.home-manager-nixos-24-11.nixosModules.home-manager
              (
                { config, ... }:
                {
                  home-manager.users.${config.mainUser} = {
                    imports = [
                      ./home-configurations/peteresselius.nix
                      ./home-modules/default.nix
                      inputs.agenix.homeManagerModules.default
                      inputs.krewfile.homeModules.krewfile
                      inputs.nix-index-database.hmModules.nix-index
                      inputs.nixvim.homeModules.nixvim
                      {
                        home.stateVersion = "24.05";
                      }
                    ];
                  };
                  home-manager.extraSpecialArgs = { inherit inputs; };
                }
              )
            ];
            specialArgs = { inherit inputs; };
          };
          starbuck = {
            arch = "aarch64";
            class = "rpi";
            deployable = true;
            nixpkgs = inputs.nixpkgs-nixos-24-11;
            modules = [
              ./nixos-configurations/starbuck.nix
              ./nixos-modules/default.nix
              inputs.raspberry-pi-nix.nixosModules.raspberry-pi
              inputs.agenix.nixosModules.default
              inputs.agenix-rekey.nixosModules.default
              inputs.authentik-nix.nixosModules.default
              inputs.microvm.nixosModules.host

              {
                microvm.vms.haos = {
                  flake = self;
                  updateFlake = "github:esselius/cfg";
                };
              }

              {
                nixpkgs-path = inputs.nixpkgs-nixos-24-11;
                nixpkgs-unstable-path = inputs.nixpkgs-unstable;
                age.rekey = {
                  hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFi1DoYv7wvIkYvTrjUVEqZI00H6d5437IgprVdFMI1+";
                  masterIdentities = [
                    {
                      identity = "/Users/peteresselius/.age-plugin-se.key";
                      pubkey = "age1se1qw3jfq82crjk5x36g7wr8pxscvlynwaxpqjt6wran7j23ped4gjsypanfet";
                    }
                    {
                      identity = "/Users/pepp/.age-plugin-se.key";
                      pubkey = "age1se1qgqzwsmme3yatp3ezp4nfncxytdp4mawpguxm2ll08dpw29sp7dxs2ls372";
                    }
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
              inputs.home-manager-nixos-24-11.nixosModules.home-manager
              (
                { config, ... }:
                {
                  home-manager.users.${config.mainUser} = {
                    imports = [
                      ./home-configurations/peteresselius.nix
                      ./home-modules/default.nix
                      inputs.agenix.homeModules.default
                      inputs.krewfile.homeModules.krewfile
                      inputs.nix-index-database.homeModules.nix-index
                      inputs.nixvim.homeModules.nixvim
                      {
                        home.stateVersion = "24.05";
                      }
                    ];
                  };
                }
              )
            ];
          };
        };
      };

      dev.enable = true;
    };
}
