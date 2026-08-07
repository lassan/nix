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

    nixd
    alejandra
    statix
    nh

    sops
    ssh-to-age

    zellij
    gh
    zoxide
    atuin
    eza
    bat
    just
    just-lsp

    temporal-cli
    tokensave

    hunk.packages.${pkgs.system}.default

    # Not needed at runtime by the zellij sidebar (home/zellij.nix wires that
    # declaratively); this is the `zj-radar setup --check` doctor and the
    # `zj-radar notify` producer shim.
    zj-radar.packages.${pkgs.system}.zj-radar-cli

    uv

    # bitwarden-cli

    typescript-language-server

    zed-editor
  ];
}
