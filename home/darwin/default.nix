{vars, ...}: {
  imports = [
    ./ghostty.nix
    ./shell.nix
    ./ssh.nix
  ];

  home.homeDirectory = "/Users/${vars.userName}";
}
