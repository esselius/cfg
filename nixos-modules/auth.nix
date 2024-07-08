{ config, lib, pkgs, mkAuthentikScope, ... }:

let
  cfg = config.auth;

  inherit (builtins) map toJSON toFile;
  inherit (lib) types mkOption mkEnableOption mkIf getAttr escapeShellArg escapeShellArgs concatMapStringsSep;

  blueprint = types.submodule ({ config, ... }: {
    options = {
      version = mkOption {
        type = types.int;
        default = 1;
      };
      metadata = {
        name = mkOption {
          type = types.str;
        };
        labels = mkOption {
          type = types.attrs;
          default = {};
        };
      };
      context = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
      entries = mkOption {
        type = types.listOf (types.submodule {
          options = {
            model = mkOption {
              type = types.str;
            };
            state = mkOption {
              type = types.str;
              default = "present";
            };
            id = mkOption {
              type = types.str;
            };
            identifiers = mkOption {
              type = types.attrsOf types.str;
            };
            attrs = mkOption {
              type = types.attrs;
            };
          };
        });
      };
      content = mkOption {
        type = types.str;
        visible = false;
        readOnly = true;
        default = toJSON { inherit (config) version metadata context entries; };
      };
      filename = mkOption {
        type = types.str;
        visible = false;
        readOnly = true;
        default = config.metadata.name + ".yaml";
      };
      file = mkOption {
        type = types.path;
        visible = false;
        readOnly = true;
        default = toFile config.filename config.content;
      };
    };
  });

  copyBlueprints = concatMapStringsSep
    "\n"
    (blueprint: "cat ${blueprint.file} | sed -E 's/\"(!(Env|KeyOf|Find) [^\"]+)\"/\\1/g' > $out/blueprints/custom/${blueprint.filename}")
    cfg.blueprints;

  customScope = (mkAuthentikScope { inherit pkgs; }).overrideScope (final: prev: {
    authentikComponents = prev.authentikComponents // {
      staticWorkdirDeps = prev.authentikComponents.staticWorkdirDeps.overrideAttrs
        (oA: {
          buildCommand = oA.buildCommand + ''
            rm -v $out/blueprints
            cp -vr ${prev.authentik-src}/blueprints $out/blueprints

            chmod 755 $out/blueprints
            mkdir $out/blueprints/custom
            ${copyBlueprints}
          '';
        });
    };
  });
in
{
  options = {
    auth = {
      enable = mkEnableOption "auth";
      env-file = mkOption {
        type = types.str;
      };
      vhost = mkOption {
        type = types.str;
      };
      listen_http = mkOption {
        type = types.str;
        default = "0.0.0.0:9000";
      };
      listen_metrics = mkOption {
        type = types.str;
        default = "0.0.0.0:9300";
      };
      blueprints = mkOption {
        type = types.listOf blueprint;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    services.authentik = {
      enable = true;
      environmentFile = cfg.env-file;
      inherit (customScope) authentikComponents;
      settings = {
        listen = {
          listen_http = cfg.listen_http;
          listen_metrics = cfg.listen_metrics;
        };
      };
    };

    services.prometheus.scrapeConfigs = [{ job_name = "authentik"; static_configs = [{ targets = [ cfg.listen_metrics ]; }]; }];
  };
}
