{
  programs.ghostty = {
    enable = true;
    # ghostty is broken on aarch64-darwin; ghostty-bin is installed
    # via modules/darwin/apps.nix instead. Setting package = null
    # still generates the config at ~/.config/ghostty/config.
    package = null;
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
