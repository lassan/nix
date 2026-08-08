_: let
  theme = import ../theme.nix;

  rgba = colour: alpha: "rgba(${builtins.substring 1 6 colour}${alpha})";
in {
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 96;
          font_family = "JetBrainsMono Nerd Font";
          color = rgba theme.foreground "ee";
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "320, 52";
          outline_thickness = 2;
          dots_size = 0.25;
          outer_color = rgba theme.accent "ff";
          inner_color = rgba theme.background "cc";
          font_color = rgba theme.foreground "ff";
          fail_color = rgba theme.red "ff";
          check_color = rgba theme.yellow "ff";
          placeholder_text = "";
          fade_on_empty = false;
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
