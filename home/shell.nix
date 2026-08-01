{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
      export PNPM_HOME="$HOME/Library/pnpm"
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac

      case ":$PATH:" in
        *":/Library/Frameworks/Python.framework/Versions/3.14/bin:"*) ;;
        *) export PATH="/Library/Frameworks/Python.framework/Versions/3.14/bin:$PATH" ;;
      esac

      eval "$(zoxide init zsh)"
      eval "$(fnm env --use-on-cd --shell zsh)"
      eval "$(temporal completion zsh)"
      # zellij's completion script ends with an unguarded `_zellij "$@"`, which
      # errors when eval'd outside a completion context. Register it properly.
      eval "$(zellij setup --generate-completion zsh | sed 's/^_zellij "\$@"$/compdef _zellij zellij/')"

      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      zvm_after_init_commands+=(
          'eval "$(atuin init zsh)"'
          'source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
        )

      zvm_after_lazy_keybindings_commands+=(
          'bindkey -M viins "\ef" forward-word'
          'bindkey -M viins "\eb" backward-word'
          'bindkey -M viins "\e[1;3C" forward-word'
          'bindkey -M viins "\e[1;3D" backward-word'
          # fzf binds its file widget to Ctrl-T, but zellij claims that for tab
          # mode (see zellij.nix) so it never reaches zsh. Alt-T is unclaimed.
          'bindkey -M viins "\et" fzf-file-widget'
          'bindkey -M vicmd "\et" fzf-file-widget'
        )

      if [[ -z "$ZELLIJ_SESSION_NAME" && ( "$TERM" == *kitty* || "$TERM" == *ghostty* ) ]]; then
        zellij attach -c $USER@$(hostname)
      fi
    '';

    # Both plugins are loaded from initContent instead: zsh-vi-mode needs to be
    # sourced before its zvm_after_init_commands hooks, and zsh-autosuggestions
    # has to load from that hook so zvm doesn't clobber its keybindings.

    shellAliases = {
      ls = "eza";
      pn = "pnpm";
      px = "pnpm exec";

      nx = "pnpm nx"; # temporary alias until I figure out dev shells for globals

      k = "kubectl";
      kns = "kubectl config set-context --current --namespace";
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
    forceOverwriteSettings = true;
  };
}
