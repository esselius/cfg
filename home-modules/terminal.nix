{ config, ... }:

{
  programs.wezterm = {
    enable = config.formfactor != "server";
    extraConfig = ''
      local config = wezterm.config_builder()

      config.color_scheme = 'Tokyo Night'

      config.window_background_opacity = 0.9
      config.macos_window_background_blur = 30

      config.window_decorations = 'RESIZE'

      config.font = wezterm.font("JetBrains Mono")

      return config
    '';
  };
}
