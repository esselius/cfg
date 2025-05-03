{ fetchFromGitHub
, buildHomeAssistantComponent
, home-assistant
, python313Packages
, pyproject-nix-lib
,
}:

buildHomeAssistantComponent rec {
  owner = "nordicopen";
  domain = "easee";
  version = "0.9.67";

  src = fetchFromGitHub {
    inherit owner;
    repo = "easee_hass";
    tag = "v${version}";
    hash = "sha256-psRr3cJ/sK/Z0dgB27GbW0qAHH2vJt+TdxqDB+Zhkc0=";
  };

  dependencies = [
    (python313Packages.callPackage ./pyeasee.nix { })
    (python313Packages.callPackage ./pysignalr.nix { inherit pyproject-nix-lib; })
  ];
  nativeBuildInputs = [
    home-assistant.python.pkgs.bump2version
  ];
}
