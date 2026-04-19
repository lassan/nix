{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

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

    temporal-cli

    github-copilot-cli
    just
    just-lsp
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

    brews = [
      "podman"
      "podman-compose"
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

      "podman-desktop"
    ];
    taps = [];
  };
}
