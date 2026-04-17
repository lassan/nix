{self, ...}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
###################################################################################
{
  system = {
    stateVersion = 6;

    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      dock = {
        autohide = true;
        magnification = false;
        autohide-delay = 0.03;
        autohide-time-modifier = 0.3;
        mineffect = "scale";
        show-recents = false;
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark"; # dark mode
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = false; # enable press and hold

        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
      };

      CustomUserPreferences = {
        "com.microsoft.VSCode" = {
          ApplePressAndHoldEnabled = false; # disable press and hold for VS Code to enable key repeat
        };
      };
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.d
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
}
