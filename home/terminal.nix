{lib, ...}: {
  options.terminal.autoStartZellij = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  imports = [
    ./shell.nix
    ./core.nix
    ./nix-index.nix
    ./vim.nix
    ./git.nix
    ./gitui.nix
    ./zellij.nix
    ./starship.nix
    ./fzf.nix
    ./glow.nix
    ./workmux.nix
    ./yazi.nix
    ./terminal-theme.nix
  ];
}
