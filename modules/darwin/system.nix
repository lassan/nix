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

      # Stylix cannot reach native macOS controls, so the accent is set here.
      # Derived from base0D rather than hand-converted, since AppleHighlightColor
      # takes floats and a literal silently drifts when the palette changes.
      CustomUserPreferences.NSGlobalDomain = {
        AppleAccentColor = 4;
        AppleHighlightColor = with config.lib.stylix.colors; "${base0D-dec-r} ${base0D-dec-g} ${base0D-dec-b} Blue";
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
