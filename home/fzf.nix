{pkgs, ...}: let
  # Non-text files fall back to a one-line type description rather than dumping
  # binary into the pane.
  fzfPreview = pkgs.writeShellScript "fzf-preview" ''
    target="$1"
    if [ -d "$target" ]; then
      ${pkgs.eza}/bin/eza --tree --level=2 --icons=always --color=always \
        --group-directories-first "$target"
    elif [ -f "$target" ]; then
      if [ "''${target##*.}" = md ]; then
        CLICOLOR_FORCE=1 ${pkgs.glow}/bin/glow -w="$FZF_PREVIEW_COLUMNS" -s=dark "$target"
      else
        case "$(${pkgs.file}/bin/file --brief --mime-type "$target")" in
          text/* | inode/x-empty | application/json | application/javascript | application/xml)
            ${pkgs.bat}/bin/bat --style=numbers --color=always --line-range=:500 "$target"
            ;;
          *)
            ${pkgs.file}/bin/file --brief "$target"
            ;;
        esac
      fi
    else
      echo "$target"
    fi
  '';

  fdFiles = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
  fdDirs = "${pkgs.fd}/bin/fd --type d --hidden --follow --exclude .git";

  # Shared so the fzf-tab override can bolt `:hidden` on without restating it.
  previewWindow = "right:60%:border-left";
in {
  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;

      defaultCommand = fdFiles;

      defaultOptions = [
        "--height 60%"
        "--layout reverse"
        "--border rounded"
        "--info inline"
        "--cycle"
        "--preview '${fzfPreview} {}'"
        "--preview-window ${previewWindow}"
        "--bind ctrl-/:toggle-preview"
        "--bind ctrl-u:preview-half-page-up"
        "--bind ctrl-d:preview-half-page-down"
      ];

      # Ctrl-T: paste a file path into the current command line.
      fileWidget = {
        command = fdFiles;
        options = ["--preview '${fzfPreview} {}'"];
      };

      # Alt-C: cd into a directory.
      changeDirWidget = {
        command = fdDirs;
        options = ["--preview '${fzfPreview} {}'"];
      };

      # Empty string yields Ctrl-R to atuin. Home Manager only detects this clash
      # when programs.atuin.enableZshIntegration is true, and shell.nix loads
      # atuin from a zsh-vi-mode hook instead, so the warning never fires.
      historyWidget.command = "";
    };

    bat = {
      enable = true;
      config.theme = "Monokai Extended";
    };

    zsh = {
      # The plugin is sourced from shell.nix, which owns load order: it binds
      # `^I` and must come after zsh-vi-mode. Only its zstyles live here, next
      # to the preview script they reference, since zsh reads zstyles at
      # completion time and their position does not matter.
      initContent = ''
        # fzf-tab can't drive the UI while zsh's own menu selection is live.
        zstyle ':completion:*' menu no
        # fzf-tab renders its group headers from these descriptions, so the format
        # has to be set for grouping (and F1/F2 group switching) to work at all.
        zstyle ':completion:*:descriptions' format '[%d]'
        # ...and an empty group-name is what splits matches into one group per tag
        # in the first place. Without it most completions arrive as a single group
        # and F1/F2 have nothing to cycle through. Note this is not scoped to
        # fzf-tab: it changes zsh's completion grouping everywhere.
        zstyle ':completion:*' group-name '''

        # -ftb-preview.tpl only exports $realpath for candidates that are actually
        # paths, which keeps the preview off things like `export <TAB>` -- the same
        # scoping the FZF_COMPLETION_*_OPTS above were written for. Non-path
        # candidates fall back to zsh's own description, which is worth reading for
        # flag completions.
        zstyle ':fzf-tab:complete:*:*' fzf-preview \
          '[[ -n $realpath ]] && ${fzfPreview} "$realpath" || print -r -- "''${desc:-$word}"'

        # fzf-tab blanks FZF_DEFAULT_OPTS unless asked not to; opt in so completion
        # inherits the border/preview-window/ctrl-/ setup from defaultOptions.
        zstyle ':fzf-tab:*' use-fzf-default-opts yes

        # ...then take back the preview pane on TAB specifically. It earns its 60%
        # on `git checkout <TAB>` and on paths, not on every `git <TAB>`, so it
        # starts hidden and ctrl-/ (bound in defaultOptions) pulls it in on demand.
        # fzf doesn't run the preview command while the window is hidden, so the
        # ones you never open cost nothing. fzf-flags land last on the command
        # line, after the inherited defaults, which is why this wins.
        zstyle ':fzf-tab:*' fzf-flags '--preview-window=${previewWindow}:hidden'
      '';
    };
  };

  # The `**<TAB>` trigger reads its own option vars, not the widget ones, so the
  # preview needs wiring separately. The PATH/DIR variants rather than
  # FZF_COMPLETION_OPTS keep it off non-path candidates like `export **<TAB>`.
  home.sessionVariables = {
    FZF_COMPLETION_PATH_OPTS = "--preview '${fzfPreview} {}'";
    FZF_COMPLETION_DIR_OPTS = "--preview '${fzfPreview} {}'";
  };
}
