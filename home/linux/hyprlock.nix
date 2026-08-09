_: {
  programs.hyprlock = {
    enable = true;

    # Attrsets rather than lists: stylix contributes colours to these same
    # options, and only attrsets merge with its definitions.
    settings = {
      general = {
        hide_cursor = true;
      };

      background = {
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      };

      label = {
        monitor = "";
        text = "$TIME";
        font_size = 96;
        position = "0, 160";
        halign = "center";
        valign = "center";
      };

      input-field = {
        monitor = "";
        size = "320, 52";
        outline_thickness = 2;
        dots_size = 0.25;
        placeholder_text = "";
        fade_on_empty = false;
        position = "0, -40";
        halign = "center";
        valign = "center";
      };
    };
  };
}
