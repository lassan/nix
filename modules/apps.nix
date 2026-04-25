{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  environment.shells = with pkgs; [
    zsh
  ];

  environment.systemPackages = with pkgs; [
    git
    vim

    # nix
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
    just
    just-lsp
    flyctl

    temporal-cli

    github-copilot-cli
    colima
    docker
  ];

  homebrew = {
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
      "ghostty"
      "bruno"
      "claude"
      "claude-code"
      "linear-linear"
      "webstorm"

      "dockdoor"
      "reader"
    ];
    taps = [];
  };
}
