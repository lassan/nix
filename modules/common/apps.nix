{
  hunk,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: _: {
      tokensave = final.callPackage ../../packages/tokensave.nix {};
    })
  ];

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
    tokensave

    hunk.packages.${pkgs.system}.default

    github-copilot-cli
    uv

    bun

    typescript-language-server
  ];
}
