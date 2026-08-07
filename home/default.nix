{
  username,
  homeDirectory,
  ...
}: {
  imports = [
    ./shell.nix
    ./core.nix
    ./vim.nix
    ./ssh.nix
    ./git.nix
    ./gitui.nix
    ./ghostty.nix
    ./firefox.nix
    ./zellij.nix
    ./starship.nix
    ./fzf.nix
    ./worktrunk.nix
    ./yazi.nix
  ];

  home = {
    inherit username homeDirectory;

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
