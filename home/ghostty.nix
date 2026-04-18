{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      macos-option-as-alt = "left";
      keybind = [
        "alt+left=unbind"
        "alt+right=unbind"
      ];

      background-opacity = 0.9;
      background-blur = true;
      theme = "Monokai Classic";
    };
  };
}
