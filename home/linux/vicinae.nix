_: {
  programs.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
      target = "graphical-session.target";
    };

    settings.pop_to_root_on_close = true;
  };
}
