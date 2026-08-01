{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      character = {
        success_symbol = "[I›](bold green)";
        error_symbol = "[I›](bold red)";
        vimcmd_symbol = "[N›](bold blue)";
        vimcmd_replace_symbol = "[C›](bold purple)";
        vimcmd_visual_symbol = "[V›](bold yellow)";
      };

      directory = {
        truncation_length = 2;
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };

      git_metrics = {
        disabled = false;
      };

      # `git status` was 19% of every command typed. The default git_status
      # renders bare symbols (`[!?]`) — enough to know *something* changed, not
      # enough to stop you running the command, so the counts are the point.
      #
      # Measured at 47ms in the 3,806-file monorepo, well inside starship's
      # 500ms `command_timeout`, so no timeout bump is needed.
      git_status = {
        # Literal `\[ \]` around the block: git_metrics renders immediately
        # before this and also uses a green `+N`, so without the brackets
        # `+489 -391 +11!1` reads as one run of numbers. Bracketed = file
        # counts, bare = line counts.
        format = "([\\[$conflicted$staged$modified$renamed$deleted$untracked$stashed$ahead_behind\\]]($style) )";

        conflicted = "[=$count](bold red)";
        staged = "[+$count](bold green)";
        modified = "[!$count](bold yellow)";
        renamed = "[»$count](bold cyan)";
        deleted = "[✘$count](bold red)";
        untracked = "[?$count](bold blue)";
        # A bare `$` is a variable sigil to starship and silently renders the
        # whole segment empty — the literal stash symbol has to be `\$`.
        stashed = "[\\$$count](bold purple)";

        ahead = "[⇡$count](bold green)";
        behind = "[⇣$count](bold red)";
        diverged = "[⇕⇡\${ahead_count}⇣\${behind_count}](bold red)";
        # Deliberately empty rather than a `✓`: up_to_date means "in sync with
        # upstream", not "clean", so a tick would sit next to `!35✘5?3` and
        # read as all-clear. Empty makes "no bracket block" mean clean *and*
        # synced, which is the unambiguous signal.
        up_to_date = "";
      };
    };
  };
}
