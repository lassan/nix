{
  username,
  homeDirectory,
  ...
}: {
  imports = [
    ./shell.nix
    ./core.nix
    ./vim.nix
    ./git.nix
    ./gitui.nix
    ./kitty.nix
    ./ghostty.nix
    ./firefox.nix
    ./zellij.nix
    ./starship.nix
    ./fzf.nix
    ./worktrunk.nix
    ./yazi.nix
  ];

  home = {
    username = username;
    homeDirectory = homeDirectory;

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
