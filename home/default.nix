{vars, ...}: {
  imports = [
    ./theme.nix
    ./terminal.nix
    ./zed.nix
    ./ssh.nix
    ./ghostty.nix
    ./firefox.nix
  ];

  # homeDirectory is set by the platform bundle beside this one, in home/linux
  # or home/darwin.
  home = {
    username = vars.userName;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
