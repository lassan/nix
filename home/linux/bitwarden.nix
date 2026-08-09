{pkgs, ...}: {
  # home/ssh.nix points IdentityAgent at a socket the desktop app owns. Nothing
  # recreates it across a reboot, so ssh fails with "Connection refused" against
  # the stale file until the app is opened by hand.
  systemd.user.services.bitwarden = {
    Unit = {
      Description = "Bitwarden desktop, which owns the SSH agent socket";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.bitwarden-desktop}/bin/bitwarden";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = ["graphical-session.target"];
  };
}
