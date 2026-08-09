{
  config,
  self,
  vars,
  ...
}: {
  networking.computerName = config.networking.hostName;

  users.users.${vars.userName} = {
    home = "/Users/${vars.userName}";
    description = vars.userName;
  };

  system = {
    stateVersion = 6;

    primaryUser = vars.userName;

    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      smb.NetBIOSName = config.networking.hostName;

      dock = {
        autohide = false;
        magnification = false;
        autohide-delay = 0.01;
        autohide-time-modifier = 0.3;
        mineffect = "scale";
        show-recents = false;
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = false; # false is what enables key repeat

        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        "com.apple.trackpad.scaling" = 1.5;

        "com.apple.keyboard.fnState" = true; # Use F1, F2, etc. keys as standard function keys.
      };

      # Stylix cannot reach native macOS controls, so the accent is set here to
      # match base0D. AppleHighlightColor takes floats, not hex.
      CustomUserPreferences.NSGlobalDomain = {
        AppleAccentColor = 4;
        AppleHighlightColor = "0.478431 0.635294 0.968627 Blue";
      };

      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.microsoft.VSCode" = {
          ApplePressAndHoldEnabled = false; # false is what enables key repeat
        };

        "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
