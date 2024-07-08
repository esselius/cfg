{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    ez-configs.url = "github:ehllie/ez-configs";

    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.ez-configs.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };

        darwin.hosts.Fox.userHomeModules = [ "peteresselius" ];
        darwin.hosts.Petere-MBP.userHomeModules = [ "peteresselius" ];
        nixos.hosts.adama.userHomeModules = [ "peteresselius" ];
      };
    };
}
