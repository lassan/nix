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

      # export DOCKER_HOST=unix:///var/run/docker.sock
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
      docker = "podman";
      pn = "pnpm";

      nx = "pnpm nx"; # temporary alias until I figure out dev shells for globals
    };
  };
}
