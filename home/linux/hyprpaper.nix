{
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.stylix) colors;

  # Generated rather than committed, so the repo carries no binary asset and the
  # wallpaper tracks the palette.
  wallpaper =
    pkgs.runCommand "stylix-gradient.png" {
      nativeBuildInputs = [pkgs.imagemagick];
    } ''
      magick -size 3840x1600 \
        radial-gradient:'${colors.withHashtag.base01}'-'${colors.withHashtag.base00}' \
        -attenuate 0.35 +noise Gaussian \
        "$out"
    '';
in {
  services.hyprpaper = {
    enable = true;

    settings = {
      preload = ["${wallpaper}"];
      wallpaper = [",${wallpaper}"];
      splash = false;
      ipc = "off";
    };
  };
}
