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
      eval "$(zellij setup --generate-completion zsh)"

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
        )

      if [[ -z "$ZELLIJ_SESSION_NAME" && ( "$TERM" == *kitty* || "$TERM" == *ghostty* ) ]]; then
        zellij attach -c $USER@$(hostname)
      fi
    '';

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
    ];

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
