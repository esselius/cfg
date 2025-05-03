{ pyproject-nix-lib, buildPythonPackage, fetchFromGitHub, python }:
let
  src = fetchFromGitHub {
    owner = "baking-bad";
    repo = "pysignalr";
    rev = "1.3.0";
    hash = "sha256-3VZuS5q4b85Kuk2B00AeVpLGO232GN8tlfu6UaGmzjE=";
  };

  project = pyproject-nix-lib.project.loadPyprojectDynamic { projectRoot = src; };
in
buildPythonPackage (project.renderers.buildPythonPackage { inherit python; })
