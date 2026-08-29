{
  config,
  pkgs,
  lib,
  ...
}: let
  # Same sources fzf.nix uses, plus a directory-only variant for the toggle below.
  fdFiles = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
  fdDirs = "${pkgs.fd}/bin/fd --type d --hidden --follow --exclude .git";

  # Inner quotes are load-bearing: fzf word-splits FZF_DEFAULT_OPTS like a shell,
  # so an unquoted reload() containing spaces is torn into separate arguments.
  extraFzfOpts = "--bind 'alt-d:reload(${fdDirs})' --bind 'alt-f:reload(${fdFiles})'";
in {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # Yazi's bundled fzf plugin shells out to a bare `Command("fzf")`, so the
    # inherited environment is the only route to fzf's `reload` action. Wrapping
    # scopes it: the same binds in fzf.nix's defaultOptions would also reach
    # fzf-tab, where swapping the candidate list for `fd` output is wrong.
    # Alt- rather than Ctrl-: fzf.nix spends Ctrl-d, and zellij claims most Ctrl
    # keys before they reach the pane.
    package = pkgs.symlinkJoin {
      name = "yazi-fzf-toggle";
      paths = [pkgs.yazi];
      nativeBuildInputs = [pkgs.makeWrapper];
      # --run rather than --suffix: --suffix word-splits its value and skips
      # tokens already present, shredding the reload() commands and dropping the
      # second --bind, since fzf.nix already puts one in FZF_DEFAULT_OPTS.
      postBuild = ''
        wrapProgram $out/bin/yazi \
          --run ${lib.escapeShellArg ''export FZF_DEFAULT_OPTS="''${FZF_DEFAULT_OPTS-} ${extraFzfOpts}"''}
      '';
    };

    # `y` rather than `yazi`, so quitting with `q` cds the shell to the last directory.
    shellWrapperName = "y";
    plugins.piper = pkgs.yaziPlugins.piper;

    # extraPackages is unset because the nixpkgs wrapper already puts ffmpeg,
    # 7zz, poppler-utils, imagemagick, resvg, chafa, fd, rg, fzf, jq and zoxide
    # on yazi's PATH. Image previews degrade to chafa unicode under zellij,
    # which forwards only sixel while ghostty implements kitty graphics and
    # refuses sixel; detach and run `y` for full fidelity.
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

      plugin.prepend_previewers = [
        {
          url = "*.md";
          run = ''piper -- CLICOLOR_FORCE=1 ${pkgs.glow}/bin/glow -w=$w -s="${config.xdg.configHome}/glow/stylix.json" "$1"'';
        }
      ];

      opener.edit = [
        {
          run = "${pkgs.vim}/bin/vim %s";
          block = true;
        }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = ["e"];
          run = "open --with=edit";
          desc = "Edit selected files";
        }
        {
          on = ["g" "r"];
          run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
          desc = "Go to the repository root";
        }
      ];
    };
  };
}
