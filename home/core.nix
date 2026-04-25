{pkgs, ...}: {
  home.packages = with pkgs; [
    # archives
    bat
    eza
    fd
    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    fzf # A command-line fuzzy finder

    # misc
    zoxide
    fnm
    gitui
    atuin
    # productivity
    glow # markdown previewer in terminal

    tldr
  ];

  programs = {
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      enableZshIntegration = true;
    };
  };
}
