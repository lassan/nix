_: {
  # ghostty is broken on aarch64-darwin, where ghostty-bin comes from
  # modules/darwin/apps.nix instead. null still generates the config, but it
  # also forces systemd.enable off, so it must not leak to Linux.
  programs.ghostty.package = null;
}
