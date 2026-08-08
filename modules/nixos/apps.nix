{pkgs, ...}: {
  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];

  # systemPackages does not install a package's udev rules, and without
  # 60-dygma.rules bazecor cannot reach the keyboard.
  services.udev.packages = [pkgs.bazecor];

  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
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
    logseq
    onedrive

    doctl
    pulumi
  ];
}
