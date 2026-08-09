_: {
  programs.ghostty = {
    enable = true;
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
