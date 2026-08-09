_: {
  # stylix.autoEnable is off in modules/common/theme.nix, so every target this
  # user wants is named here. Platform-specific targets live beside their
  # modules, in home/linux.
  stylix.targets = {
    ghostty.enable = true;
    zellij.enable = true;

    bat.enable = true;
    fzf.enable = true;
    gitui.enable = true;
    yazi.enable = true;
    vim.enable = true;
  };
}
