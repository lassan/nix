{
  pkgs,
  vars,
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
    username = vars.userName;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${vars.userName}"
      else "/home/${vars.userName}";

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
