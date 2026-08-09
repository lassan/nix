{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
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
    logseq
    onedrive

    doctl
    pulumi
  ];
}
