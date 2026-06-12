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
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    masApps = {
      vimari = 1480933944;
    };

    brews = [
      "asimov"
      "doctl" #digital ocean cli
      "pulumi"
      "llmfit"
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
      "claude-code@latest"
      "linear"
      "webstorm"
      "cyberduck"

      "dockdoor"
      "reader"

      "shortcat"

      "microsoft-outlook"
      "microsoft-excel"

      "macs-fan-control"

      "jordanbaird-ice"
      "stats"

      "dash"
      # "lookaway"

      "ollama"

      "citrix-workspace"
    ];
  };
}
