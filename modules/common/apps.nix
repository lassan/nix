{
  hunk,
  pkgs,
  zj-radar,
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
    nh # darwin-rebuild/nixos-rebuild wrapper: package diff per generation, GC with a retention policy

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

    # Not needed at runtime by the zellij sidebar (home/zellij.nix wires that
    # declaratively); this is the `zj-radar setup --check` doctor and the
    # `zj-radar notify` producer shim.
    zj-radar.packages.${pkgs.system}.zj-radar-cli

    github-copilot-cli
    uv

    bitwarden-cli

    bun

    typescript-language-server

    zed-editor
  ];
}
