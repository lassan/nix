{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # terminal
    ghostty

    # hyprland desktop
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

    # apps (mirroring homebrew casks/brews where available)
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

    # cli tools
    doctl
    pulumi
  ];
}
