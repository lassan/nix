{vars, ...}: {
  imports = [
    ./ghostty.nix
    ./hindsight.nix
    ./shell.nix
    ./ssh.nix
    ./zellij-daemon.nix
  ];

  home = {
    homeDirectory = "/Users/${vars.userName}";

    # system.defaults.screencapture.location points here.
    file."Screenshots/.keep".text = "";
  };
}
