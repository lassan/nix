{pkgs, ...}: {
  home.packages = with pkgs; [
    bat
    fd
    ripgrep
    jq
    zoxide
    glow
    tldr

    gh
    just
    just-lsp
    uv
    fnm
    pi-coding-agent

    nixd
    alejandra
    statix
    typescript-language-server

    temporal-cli
    tuicr
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
