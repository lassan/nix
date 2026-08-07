{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty

    hyprpaper
    hyprlock
    wofi
    waybar
    dunst
    grim
    slurp
    wl-clipboard
    networkmanagerapplet
    playerctl

    vscode-fhs
    tailscale
    spotify
    bitwarden-desktop
    slack
    discord
    karere
    bazecor
    bruno
    claude-code
    jetbrains.webstorm
    ollama-cuda
    logseq
    onedrive

    doctl
    pulumi
  ];
}
