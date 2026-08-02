{self, ...}: {
  system = {
    stateVersion = 6;

    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
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
