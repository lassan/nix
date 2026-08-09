{pkgs, ...}: {
  stylix = {
    enable = true;

    polarity = "dark";

    # The plain tokyo-night-dark scheme misfiles its accents: base08, which
    # becomes ANSI red, holds a pale blue, so diffs and error states lose their
    # red. The terminal- variant maps the accents correctly; its background and
    # foreground are the only things worth taking back from tokyo-night-dark.
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";
    override = {
      base00 = "#1a1b26";
      # Would otherwise equal the new base00, flattening everything that relies
      # on the two differing: the hyprpaper gradient, tooltips, inactive borders.
      base01 = "#16161e";
      # Ships at 2.0:1 against the background, below even the large-text floor.
      base03 = "#565f89";
      base05 = "#a9b1d6";
      # Teal in the scheme, which collides with cyan and makes diff additions
      # unreadable.
      base0B = "#9ece6a";
    };

    # No wallpaper: the Hyprland setup draws its own gradient, and darwin has no
    # target for one. Targets that require an image opt in via lib.stylix.pixel.
    image = null;

    # Targets are named one by one in home/theme.nix and home/linux/theme.nix,
    # so a newly installed program never silently acquires theming.
    autoEnable = false;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      # Drives notifications, the vicinae launcher and GTK/Qt chrome. Narrowed
      # to the one family because the full google-fonts set is 2.3G.
      sansSerif = {
        package = pkgs.google-fonts.override {fonts = ["SUSE"];};
        name = "SUSE";
      };
    };

    # Installs the fonts above; without it every target names a font the system
    # has not got.
    targets.font-packages.enable = true;
  };
}
