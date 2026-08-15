{vars, ...}: {
  imports = [
    ./ghostty.nix
    ./shell.nix
    ./ssh.nix
    ./zellij-daemon.nix
  ];

  home.homeDirectory = "/Users/${vars.userName}";
}
