{
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "audiconnect";
  domain = "audiconnect";
  version = "1.11.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "audi_connect_ha";
    tag = "v${version}";
    hash = "sha256-vijLvhs3+osTBNO96Poyc58yFJLuMVegoW+eEiEhtrM=";
  };

  dependencies = [
    home-assistant.python.pkgs.beautifulsoup4
  ];
}
