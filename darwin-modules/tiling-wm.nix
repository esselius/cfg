{ pkgs, ... }:

{
  services = {
    yabai = {
      enable = true;

      config = {
        external_bar = "all:26:0";
        layout = "bsp";

        top_padding = "10";
        bottom_padding = "10";
        left_padding = "10";
        right_padding = "10";
        window_gap = "10";

        auto_balance = "on";

        mouse_modifier = "alt";
        mouse_drop_action = "swap";
      };
    };

    spacebar = {
      enable = true;
      package = pkgs.spacebar;

      config = {
        position = "top";
        height = 26;
      };
    };

    skhd = {
      enable = true;

      skhdConfig = ''
        # move window
        shift + cmd - h : yabai -m window --warp west  || yabai -m window --display west
        shift + cmd - j : yabai -m window --warp south || yabai -m window --display south
        shift + cmd - k : yabai -m window --warp north || yabai -m window --display north
        shift + cmd - l : yabai -m window --warp east  || yabai -m window --display east

        # toggle split
        shift + alt - space : yabai -m window --toggle split

        # rebalance space
        shift + cmd - space  : yabai -m space --balance

        # toggle fullscreen
        shift + cmd - return : yabai -m window --toggle zoom-fullscreen

        # open terminal
        # alt - return         : open -a kitty
      '';
    };
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        "com.apple.trackpad.forceClick" = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "Always";
        ApplePressAndHoldEnabled = false;
        _HIHideMenuBar = true;
      };
      LaunchServices.LSQuarantine = false;
      ActivityMonitor.ShowCategory = 100;
      trackpad = {
        ActuationStrength = 0;
        Clicking = false;
        TrackpadThreeFingerTapGesture = 0;
      };
      universalaccess = {
        closeViewScrollWheelToggle = true;
        reduceMotion = true;
        reduceTransparency = false;
      };
      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      dock = {
        autohide = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
      remapCapsLockToEscape = true;
    };
  };
}
