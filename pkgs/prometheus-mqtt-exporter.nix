{ python312Packages, fetchPypi }:

python312Packages.buildPythonPackage rec {
  pname = "mqtt_exporter";
  version = "1.4.7";
  src = fetchPypi {
    inherit pname version;
    sha256 = "R1uXK6Yk0FtpBNqhm1QwfmDlqzR9i75AdvCBxpq/8+w=";
  };
  format = "pyproject";
  propagatedBuildInputs = [
    python312Packages.paho-mqtt_2
    python312Packages.prometheus-client
    python312Packages.setuptools
  ];
}
