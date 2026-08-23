_: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      macos-option-as-alt = "left";

      background-blur = true;
      confirm-close-surface = false;

      # match macOS Terminal.app's "Clear Dark" profile
      background = "191D27";
      foreground = "E0E0E0";
      cursor-color = "8B8B8B";
      font-family = "SF Mono";
      font-size = 12;
    };
  };
}
