_: {
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 420;
        height = 200;
        origin = "top-right";
        offset = "16x48";
        corner_radius = 10;
        frame_width = 2;
        gap_size = 6;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        icon_position = "left";
        max_icon_size = 48;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action";
        mouse_right_click = "close_all";
      };

      urgency_low.timeout = 5;
      urgency_normal.timeout = 8;
      urgency_critical.timeout = 0;
    };
  };
}
