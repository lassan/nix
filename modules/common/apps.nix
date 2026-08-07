{pkgs, ...}: {
  environment.shells = with pkgs; [
    zsh
  ];

  # System level is for what has to work before or without home-manager, plus
  # GUI bundles, which nix-darwin links into /Applications/Nix Apps. Everything
  # else a shell reaches for lives in home/.
  environment.systemPackages = with pkgs; [
    git
    vim

    nh
    sops
    ssh-to-age

    zed-editor
  ];
}
