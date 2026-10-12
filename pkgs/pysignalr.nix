{ pyproject-nix-lib
, buildPythonPackage
, fetchFromGitHub
, python
,
}:
let
  src = fetchFromGitHub {
    owner = "baking-bad";
    repo = "pysignalr";
    rev = "1.3.2";
    hash = "sha256-/Wa2ZeIuvF/4hM79N0rL0DxrBV60BM8/4uvV6ma79Xk=";
  };

  project = pyproject-nix-lib.project.loadPyprojectDynamic { projectRoot = src; };
in
buildPythonPackage (project.renderers.buildPythonPackage { inherit python; })
