{pkgs, ...}: {
  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    jq

    zoxide
    gitui
    glow

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
