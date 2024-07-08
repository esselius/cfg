{ ezModules, osConfig, ... }:

{
  imports = [
    ezModules.context
    ezModules.agenix
  ];

  context = osConfig.context;
}
