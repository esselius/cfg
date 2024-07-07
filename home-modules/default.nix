{ ezModules, osConfig, ... }:

{
  imports = [
    ezModules.context
  ];

  context = osConfig.context;
}