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

      # The default bare symbols (`[!?]`) say something changed but not enough
      # to skip running `git status`, which was 19% of commands typed; the
      # counts are the point. Measured at 47ms in a 3,806-file monorepo, inside
      # starship's 500ms `command_timeout`.
      git_status = {
        # Literal `\[ \]`: git_metrics renders immediately before this and also
        # uses a green `+N`, so unbracketed `+489 -391 +11!1` reads as one run
        # of numbers. Bracketed is file counts, bare is line counts.
        format = "([\\[$conflicted$staged$modified$renamed$deleted$untracked$stashed$ahead_behind\\]]($style) )";

        conflicted = "[=$count](bold red)";
        staged = "[+$count](bold green)";
        modified = "[!$count](bold yellow)";
        renamed = "[»$count](bold cyan)";
        deleted = "[✘$count](bold red)";
        untracked = "[?$count](bold blue)";
        # A bare `$` is a variable sigil to starship and silently empties the
        # whole segment, so the literal stash symbol has to be `\$`.
        stashed = "[\\$$count](bold purple)";

        ahead = "[⇡$count](bold green)";
        behind = "[⇣$count](bold red)";
        diverged = "[⇕⇡\${ahead_count}⇣\${behind_count}](bold red)";
        # Empty rather than a `✓`: up_to_date means in sync with upstream, not
        # clean, so a tick would sit beside `!35✘5?3` and read as all-clear.
        up_to_date = "";
      };
    };
  };
}
