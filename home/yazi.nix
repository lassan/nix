{
  pkgs,
  lib,
  ...
}: let
  # Mirrors the sources fzf.nix hands FZF_DEFAULT_COMMAND, plus a directory-only
  # variant, so the toggle below just swaps fzf's candidate list between them.
  fdFiles = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
  fdDirs = "${pkgs.fd}/bin/fd --type d --hidden --follow --exclude .git";

  # The inner quotes are load-bearing: fzf word-splits FZF_DEFAULT_OPTS the way
  # a shell would, so an unquoted reload() containing spaces would be torn into
  # separate arguments.
  extraFzfOpts = "--bind 'alt-d:reload(${fdDirs})' --bind 'alt-f:reload(${fdFiles})'";
in {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # Yazi's bundled fzf plugin shells out to a bare `Command("fzf")` with no
    # --bind of its own, so the only way to reach fzf's `reload` action is
    # through the environment it inherits. Wrapping yazi keeps that scoped:
    # putting the same binds in fzf.nix's defaultOptions would also inject them
    # into fzf-tab completions and `ns`, where swapping the candidate list for
    # `fd` output is actively wrong.
    #
    # Alt-d / Alt-f rather than Ctrl-d / Ctrl-f: fzf.nix already spends Ctrl-d
    # on preview-half-page-down, and zellij claims most Ctrl keys before they
    # ever reach the pane. Neither Alt-d nor Alt-f is bound in zellij.
    package = pkgs.symlinkJoin {
      name = "yazi-fzf-toggle";
      paths = [pkgs.yazi];
      nativeBuildInputs = [pkgs.makeWrapper];
      # --run rather than --suffix: makeWrapper's --suffix word-splits its value
      # and skips any token already present, which both shreds the reload()
      # commands and drops the second --bind (FZF_DEFAULT_OPTS already carries
      # one from fzf.nix). Appending by hand keeps those defaults intact.
      postBuild = ''
        wrapProgram $out/bin/yazi \
          --run ${lib.escapeShellArg ''export FZF_DEFAULT_OPTS="''${FZF_DEFAULT_OPTS-} ${extraFzfOpts}"''}
      '';
    };

    # `y` instead of `yazi`, so quitting with `q` cds the shell to the last
    # directory you were browsing.
    shellWrapperName = "y";
    plugins.piper = pkgs.yaziPlugins.piper;

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

      plugin.prepend_previewers = [
        {
          url = "*.md";
          run = ''piper -- CLICOLOR_FORCE=1 ${pkgs.glow}/bin/glow -w=$w -s=dark "$1"'';
        }
      ];

      opener.edit = [
        {
          run = ''${pkgs.vim}/bin/vim "$@"'';
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
