{...}: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # `y` instead of `yazi`, so quitting with `q` cds the shell to the last
    # directory you were browsing.
    shellWrapperName = "y";

    # No extraPackages needed: the nixpkgs yazi wrapper already puts ffmpeg,
    # 7zz, poppler-utils, imagemagick, resvg, chafa, fd, rg, fzf, jq and
    # zoxide on yazi's PATH.
    #
    # Image previews fall back to chafa's unicode art inside zellij: zellij
    # only forwards sixel, and ghostty implements kitty graphics but refuses
    # sixel, so no real image protocol survives the multiplexer. Detach from
    # zellij and run `y` for full-fidelity previews.

    settings = {
      mgr = {
        ratio = [1 3 4];
        show_hidden = true;
        show_symlink = true;
        sort_by = "natural";
        sort_dir_first = true;
        sort_sensitive = false;
        linemode = "size";
      };

      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = ["g" "r"];
          run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
          desc = "Go to the repository root";
        }
      ];
    };
  };
}
