{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./terminal.nix
    ./linux/shell.nix
    ../modules/common/theme.nix
  ];

  home = {
    username = "sprite";
    homeDirectory = "/home/sprite";
    stateVersion = "25.11";
    packages = [pkgs.nix];
  };

  workmux.enable = false;

  programs.home-manager.enable = true;
  programs.zsh.profileExtra = ''
    export USER="$(id -un)"
    export SHELL="$HOME/.nix-profile/bin/zsh"
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  '';
  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = false;
  stylix.targets.font-packages.enable = lib.mkForce false;

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = true;
      keep-derivations = true;
    };
  };
}
