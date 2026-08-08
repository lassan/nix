{pkgs, ...}: let
  theme = import ../theme.nix;

  # Generated rather than committed, so the repo carries no binary asset and the
  # wallpaper tracks the palette.
  wallpaper =
    pkgs.runCommand "monokai-gradient.png" {
      nativeBuildInputs = [pkgs.imagemagick];
    } ''
      magick -size 3840x1600 \
        radial-gradient:'${theme.backgroundAlt}'-'${theme.background}' \
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
