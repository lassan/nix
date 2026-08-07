{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    # ghostty is broken on aarch64-darwin; ghostty-bin is installed via
    # modules/darwin/apps.nix instead. package = null still generates the
    # config at ~/.config/ghostty/config, but it also forces systemd.enable
    # off, so it must not leak to Linux.
    package =
      if pkgs.stdenv.isDarwin
      then null
      else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      macos-option-as-alt = "left";

      background-opacity = 1;
      background-blur = true;
      theme = "Monokai Classic";
      confirm-close-surface = false;
    };
  };
}
