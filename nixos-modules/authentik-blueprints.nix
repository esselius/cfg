{ config, lib, pkgs, mkAuthentikScope, ... }:

let
  cfg = config.services.authentik.blueprints;

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
          default = { };
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
    (blueprint: "sed -E 's/\"(!(Env|KeyOf|Find) [^\"]+)\"/\\1/g' < ${blueprint.file} > $out/blueprints/custom/${blueprint.filename}")
    cfg;

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
    services.authentik.blueprints = mkOption {
      type = types.listOf blueprint;
      default = [ ];
    };
  };

  config = {
    services.authentik = mkIf (config.services.authentik.blueprints != [ ]) {
      inherit (customScope) authentikComponents;
    };
  };
}
