{vars, ...}: {
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

  # homeDirectory is set by the platform bundle beside this one, in home/linux
  # or home/darwin.
  home = {
    username = vars.userName;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
