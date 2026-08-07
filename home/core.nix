{
  inputs,
  pkgs,
  ...
}: {
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

    nixd
    alejandra
    statix
    typescript-language-server

    temporal-cli
    tokensave

    inputs.hunk.packages.${pkgs.system}.default
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
