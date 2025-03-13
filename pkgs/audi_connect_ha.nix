{
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "audiconnect";
  domain = "audiconnect";
  version = "1.11.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = "v${version}";
    hash = "sha256-OgNAIUxXTKqLEhP6GaVydcl7zIYko+wy3hPucX++R1I=";
  };

  dependencies = [
    home-assistant.python.pkgs.beautifulsoup4
  ];
}
