{ lib, pkgs, config, ... }:

let
  cfg = config.profiles.tools;
  inherit (lib) mkMerge mkIf;
in
{
  options.profiles.tools = {
    asdf = lib.mkEnableOption "Install asdf";
    k8s = lib.mkEnableOption "Install k8s packages & set shell config";
    minio = lib.mkEnableOption "Install minio packages";
    task = lib.mkEnableOption "Install task tab completion";
    trino = lib.mkEnableOption "Install trino packages";
    google-cloud = lib.mkEnableOption "Install google cloud packages";
  };

  config = mkMerge [
    (mkIf cfg.asdf {
      home = {
        file.".asdf".source = pkgs.fetchFromGitHub {
          owner = "asdf-vm";
          repo = "asdf";
          rev = "v0.8.0";
          sha256 = "sha256-E4mN94QITyqxypvWjzLi21XKP+D1M6ya4vTJr9oQ9h4=";
        };

        sessionVariables = {
          ASDF_DATA_DIR = "$HOME/.asdf-data";
        };
      };

      programs.fish.shellInit = ''
        source $HOME/.asdf/asdf.fish
      '';
    })

    (mkIf cfg.k8s {
      programs = {
        fish = {
          shellAbbrs = {
            k = "kubectl";
            kcuc = "kubectl config use-context";
            kccc = "kubectl config current-context";
          };
        };
      };

      home.packages = with pkgs; [
        k9s
        krew
        minio-client
        sqlfluff
        stern
        kubectl
      ];

      home.sessionPath = [
        "$HOME/.krew/bin"
      ];
    })

    (mkIf cfg.minio {
      home.packages = with pkgs; [
        minio-client
      ];
    })

    (mkIf cfg.task {
      xdg.configFile."fish/completions/task.fish".source = "${pkgs.go-task}/share/fish/vendor_completions.d/task.fish";
    })

    (mkIf cfg.trino {
      home.packages = with pkgs; [
        trino-cli
      ];
    })

    (mkIf cfg.google-cloud {
      home.packages = with pkgs; [
        google-cloud-sdk
      ];
    })
  ];
}
