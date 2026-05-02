{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
      eval "$(zoxide init zsh)"
      eval "$(fnm env --use-on-cd --shell zsh)"
      eval "$(temporal completion zsh)"
    '';

    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      zvm_after_init_commands+=(
          'eval "$(atuin init zsh)"'
        )
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
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
    forceOverwriteSettings = true;
  };
}
