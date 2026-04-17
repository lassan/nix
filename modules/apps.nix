{pkgs, ...}: {
  environment.shells = with pkgs; [
    zsh
  ];

  environment.systemPackages = with pkgs; [
    git
    vim

    # nix
    nixfmt
    nixd
    alejandra

    # dev tools
    zellij
    fnm
    gh
    zoxide
    atuin
    eza
    bat
    gitui
    temporal-cli
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    masApps = {
      vimari = 1480933944;
    };

    brews = [];
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

      # dev tool
      "ghostty"
      "bruno"
      "claude"
      "claude-code"
      "linear-linear"
      "webstorm"
    ];
    taps = [];
  };
}
