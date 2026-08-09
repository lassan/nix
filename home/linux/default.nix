{vars, ...}: {
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./vicinae.nix
    ./dunst.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
    ./bitwarden.nix
    ./firefox.nix
    ./shell.nix
  ];

  home.homeDirectory = "/home/${vars.userName}";
}
