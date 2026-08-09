{pkgs, ...}: {
  stylix = {
    enable = true;

    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

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
