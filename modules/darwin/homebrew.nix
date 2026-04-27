{
  username,
  homebrew-core,
  homebrew-cask,
  config,
  ...
}: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;

    user = username;

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };

    mutableTaps = false;
  };

  homebrew = {
    taps = builtins.attrNames config.nix-homebrew.taps;

    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };

    masApps = {
      vimari = 1480933944;
    };

    brews = [
      "asimov"
    ];
    casks = [
      "zen"
      "rectangle"
      "raycast"
      "tailscale-app"
      "spotify"
      "bitwarden"

      "slack"
      "discord"
      "whatsapp"

      "bazecor"

      # dev tool
      # "ghostty"
      "bruno"
      "claude"
      "claude-code"
      "linear-linear"
      "webstorm"

      "dockdoor"
      "reader"

      "stats"
      "shortcat"
    ];
  };
}
