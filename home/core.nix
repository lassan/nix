{pkgs, ...}: {
  home.packages = with pkgs; [
    # archives
    bat
    eza
    fd
    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    # fzf comes from programs.fzf in fzf.nix

    # misc
    zoxide
    fnm
    gitui
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
