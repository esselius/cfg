{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "pyeasee";
  version = "0.8.11";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+g3g8yGBVJdABHqt/w7Wq1gh+nqMF3a+2G3MW4yWeGg=";
  };
}
