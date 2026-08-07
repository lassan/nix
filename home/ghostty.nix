{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    # ghostty is broken on aarch64-darwin, where ghostty-bin comes from
    # modules/darwin/apps.nix instead. null still generates the config, but it
    # also forces systemd.enable off, so it must not leak to Linux.
    package =
      if pkgs.stdenv.isDarwin
      then null
      else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      macos-option-as-alt = "left";

      background-opacity = 1;
      background-blur = true;
      theme = "Monokai Classic";
      confirm-close-surface = false;
    };
  };
}
