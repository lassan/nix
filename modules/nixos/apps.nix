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
    zen-browser
    tailscale
    spotify
    bitwarden
    slack
    discord
    whatsapp-for-linux
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
