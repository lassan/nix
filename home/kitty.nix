{
  programs.kitty = {
    enable = true;

    shellIntegration.enableZshIntegration = true;

    themeFile = "Monokai";

    keybindings = {
      "alt+left" = "no_op";
      "alt+right" = "no_op";
    };

    settings = {
      macos_option_as_alt = "left";

      background_opacity = "0.75";
      background_blur = 64;
    };
  };
}
