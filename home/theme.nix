# Monokai Classic, matching the ghostty theme in home/ghostty.nix. Imported by
# the hyprland, waybar, wofi and dunst modules so they cannot drift apart.
rec {
  background = "#272822";
  backgroundAlt = "#1D1E19";
  foreground = "#F8F8F2";
  comment = "#75715E";

  red = "#F92672";
  orange = "#FD971F";
  yellow = "#E6DB74";
  green = "#A6E22E";
  cyan = "#66D9EF";
  purple = "#AE81FF";

  accent = red;
  accentAlt = purple;

  # Hyprland takes colours as 0xAARRGGBB rather than #RRGGBB.
  hypr = colour: alpha: "0x${alpha}${builtins.substring 1 6 colour}";
}
