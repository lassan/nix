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
    uv

    bun

    typescript-language-server
  ];
}
