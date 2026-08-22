{
  config,
  self,
  vars,
  ...
}: {
  networking.computerName = config.networking.hostName;

  programs.zsh.enableGlobalCompInit = false;

  users.users.${vars.userName} = {
    home = "/Users/${vars.userName}";
    description = vars.userName;
  };

  system = {
    stateVersion = 6;

    primaryUser = vars.userName;

    configurationRevision = self.rev or self.dirtyRev or null;

    # hidutil applies this at activation only; the equivalent ByHost plist the
    # Settings UI writes is what carries it across a reboot.
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      smb.NetBIOSName = config.networking.hostName;

      dock = {
        autohide = false;
        magnification = false;
        autohide-delay = 0.01;
        autohide-time-modifier = 0.3;
        mineffect = "scale";
        show-recents = false;

        # Spaces keep their creation order, so the Rectangle hyper bindings
        # always land on the same one.
        mru-spaces = false;

        expose-group-apps = true;

        wvous-br-corner = 1; # 1 is Disabled; the default there is Quick Note.
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = false; # false is what enables key repeat

        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        "com.apple.trackpad.scaling" = 1.5;

        "com.apple.keyboard.fnState" = true; # Use F1, F2, etc. keys as standard function keys.

        # Substitution mangles code, paths and quotes in every native text field.
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;

        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Ctrl-cmd-drag moves a window from anywhere in its body.
        NSWindowShouldDragOnGesture = true;

        NSDocumentSaveNewDocumentsToCloud = false;
        AppleShowAllExtensions = true;

        "com.apple.sound.beep.feedback" = 0;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        FXDefaultSearchScope = "SCcf"; # Search the current folder, not This Mac.
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        QuitMenuItem = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
        TrackpadRightClick = true;
      };

      # Directory created in home/darwin/default.nix; screencapture silently
      # falls back to the desktop if it does not exist.
      screencapture = {
        location = "~/Screenshots";
        type = "png";
        disable-shadow = true;
        show-thumbnail = false; # Otherwise the file only lands after a 5s preview.
      };

      WindowManager = {
        GloballyEnabled = false; # Stage Manager.
        EnableStandardClickToShowDesktop = false;
      };

      LaunchServices.LSQuarantine = false;

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
