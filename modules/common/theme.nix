{pkgs, ...}: {
  stylix = {
    enable = true;

    polarity = "dark";

    # The plain tokyo-night-dark scheme misfiles its accents: base08, which
    # becomes ANSI red, holds a pale blue, so diffs and error states lose their
    # red. The terminal- variant maps the accents correctly; its background and
    # foreground are the only things worth taking back from tokyo-night-dark.
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";
    # base0B is teal in the scheme, which collides with cyan and makes diff
    # additions unreadable; #9ece6a is upstream Tokyo Night's green.
    # base01 would otherwise equal the new base00, flattening the surfaces that
    # rely on the two differing: the hyprpaper gradient, tooltips, inactive
    # borders. It takes the background the scheme originally shipped.
    override = {
      base00 = "#1a1b26";
      base01 = "#16161e";
      base05 = "#a9b1d6";
      base0B = "#9ece6a";
    };

    # No wallpaper: the Hyprland setup draws its own gradient, and darwin has no
    # target for one. Targets that require an image opt in via lib.stylix.pixel.
    image = null;

    # Targets are enabled explicitly below so a newly installed program never
    # silently acquires theming.
    autoEnable = false;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
    };
  };
}
