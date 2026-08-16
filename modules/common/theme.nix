{pkgs, ...}: {
  stylix = {
    enable = true;

    polarity = "dark";

    # Every replacement below is a value from IBM's own Carbon ramps, so the
    # scheme stays coherent rather than becoming a hand-mix.
    base16Scheme = "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    override = {
      # Ships at 2.3:1 against the background, below the large-text floor.
      base03 = "#6f6f6f";
      # Near-white in the dark-foreground slot, which yazi draws its borders
      # and separators in.
      base04 = "#a8a8a8";
      # Teal in the lightest slot, so ANSI bright white renders teal.
      base07 = "#ffffff";
      # Magenta-pink in the red slot: errors and diff deletions lose their red.
      base08 = "#fa4d56";
      # Pink in the orange slot.
      base09 = "#ff832b";
      # Orange in the yellow slot, leaving no yellow anywhere in ANSI.
      base0A = "#f1c21b";
      # Duplicates base0D; reclaims the pink displaced from base09.
      base0F = "#ff7eb6";
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
