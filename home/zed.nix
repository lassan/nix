_: {
  # zed-editor stays in modules/common/apps.nix so nix-darwin keeps linking the
  # bundle into /Applications; null here generates settings without a second
  # install.
  programs.zed-editor = {
    enable = true;
    package = null;
  };
}
