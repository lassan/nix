{
  username,
  brew-src,
  homebrew-core,
  homebrew-cask,
  homebrew-can1357,
  homebrew-rtk-ai,
  config,
  ...
}: let
  # nix-homebrew derives this from its own bundled lock, which still says
  # 6.0.12, so overriding brew-src alone would stamp the wrong HOMEBREW_VERSION.
  # Read the tag we actually pinned in flake.nix instead.
  brewVersion = (builtins.fromJSON (builtins.readFile ../../flake.lock)).nodes.brew-src.original.ref;
in {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;

    user = username;

    package =
      brew-src
      // {
        name = "brew-${brewVersion}";
        version = brewVersion;
      };

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "can1357/homebrew-tap" = homebrew-can1357;
      "rtk-ai/homebrew-tap" = homebrew-rtk-ai;
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
      "doctl"
      "pulumi"
      "llmfit"

      "herdr"

      "rtk-ai/tap/rtk"
    ];
    casks = [
      "rectangle"
      "raycast"
      "tailscale-app"
      "spotify"
      "bitwarden"

      "slack"
      "discord"
      "whatsapp"

      "bazecor"

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
      "onedrive"

      "macs-fan-control"

      "jordanbaird-ice"
      "stats"

      "dash"
      "lookaway"

      "ollama-app"

      "citrix-workspace"

      "logseq"
      "opensuperwhisper"

      "codex"

      "gitbutler"
    ];
  };
}
