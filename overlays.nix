{ inputs
, pkgs
, ...
}:
let
  unstable-pkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv) system;
    config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "claude-code" ];
  };
in
{
  nixpkgs.overlays = [
    (_final: prev: {
      darwin = prev.darwin.overrideScope (
        _: _: {
          inherit (unstable-pkgs.darwin) linux-builder;
        }
      );

      inherit (unstable-pkgs) opencode claude-code;
    })
  ];
}
