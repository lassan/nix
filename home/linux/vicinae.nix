_: let
  theme = import ../theme.nix;
in {
  programs.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
      target = "graphical-session.target";
    };

    settings = {
      font.normal.size = 11;
      pop_to_root_on_close = true;
      theme.dark.name = "monokai-classic";
    };

    themes.monokai-classic = {
      meta = {
        version = 1;
        name = "Monokai Classic";
        description = "Matches the ghostty and waybar palette";
        variant = "dark";
        inherits = "vicinae-dark";
      };

      colors = {
        core = {
          inherit (theme) background foreground accent;
          secondary_background = theme.backgroundAlt;
          border = theme.comment;
        };

        accents = {
          inherit (theme) red orange yellow green cyan purple;
          blue = theme.cyan;
          magenta = theme.red;
        };
      };
    };
  };
}
