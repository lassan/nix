{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
      . "$HOME/.atuin/bin/env"
      eval "$(atuin init zsh)"
      eval "$(zoxide init zsh)"
      eval "$(fnm env --use-on-cd --shell zsh)"
      eval "$(temporal completion zsh)"

      if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
    '';

    zplug = {
      enable = true;
      plugins = [
        {name = "jeffreytse/zsh-vi-mode";}
        {name = "zsh-users/zsh-autosuggestions";}
      ];
    };

    shellAliases = {
      ls = "eza";
      pn = "pnpm";
      px = "pnpm exec";

      nx = "pnpm nx"; # temporary alias until I figure out dev shells for globals
    };
  };
}
