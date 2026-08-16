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
    zed.enable = true;

    # starship.nix writes ANSI colour names, which this target turns into a
    # named palette of exact base16 values rather than terminal approximations.
    starship.enable = true;

    firefox = {
      enable = true;
      profileNames = ["default"];
    };
  };
}
