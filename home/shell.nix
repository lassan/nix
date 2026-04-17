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
    };
  };
}
