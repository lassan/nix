{vars, ...}: {
  imports = [
    ./theme.nix
    ./shell.nix
    ./core.nix
    ./nix-index.nix
    ./vim.nix
    ./zed.nix
    ./ssh.nix
    ./git.nix
    ./gitui.nix
    ./ghostty.nix
    ./firefox.nix
    ./zellij.nix
    ./starship.nix
    ./fzf.nix
    ./glow.nix
    ./worktrunk.nix
    ./yazi.nix
    ./tuicr.nix
  ];

  # homeDirectory is set by the platform bundle beside this one, in home/linux
  # or home/darwin.
  home = {
    username = vars.userName;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
