{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;

      # Atuin owns Ctrl-R but does not back zsh's own history: up-arrow, `!!`,
      # `!$` and `fc` still read $HISTFILE. ignoreSpace keeps a command carrying
      # a token out of the file entirely.
      history = {
        size = 100000;
        save = 100000;
        ignoreDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
      };
      initContent = ''
        eval "$(zoxide init zsh)"
        eval "$(fnm env --use-on-cd --shell zsh)"
        eval "$(temporal completion zsh)"
        # zellij's completion script ends with an unguarded `_zellij "$@"`, which
        # errors when eval'd outside a completion context. Register it properly.
        eval "$(zellij setup --generate-completion zsh | sed 's/^_zellij "\$@"$/compdef _zellij zellij/')"

        # Carapace compdefs all of its ~650 static specs unconditionally, displacing
        # both zsh's bundled completers (`_git` knows your branches, a spec doesn't)
        # and the ones tools ship into site-functions. So it fills gaps and never
        # displaces: snapshot what compinit found, source carapace, hand back every
        # command that already had an owner. Diffing rather than CARAPACE_EXCLUDES
        # means the list can't rot as tools gain their own completers.
        typeset -A _comps_before
        _comps_before=("''${(@kv)_comps}")
        source <(${lib.getExe config.programs.carapace.package} _carapace zsh)
        for _c in "''${(@k)_comps_before}"; do
          [[ ''${_comps[$_c]} == _carapace_completer ]] && _comps[$_c]=''${_comps_before[$_c]}
        done
        unset _comps_before _c

        # zsh-vi-mode otherwise appends zvm_init to precmd_functions and initializes
        # after this whole file, overwriting its keybindings on the way past.
        # Sourcing mode runs zvm_init here, so everything below is plain zsh startup
        # in the order written: load after the thing you intend to override.
        ZVM_INIT_MODE=sourcing
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

        eval "$(atuin init zsh)"
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

        # Here rather than fzf.nix so it lands after zvm; its zstyles live there and
        # are read at completion time, so their position doesn't matter.
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        # Alt-f goes to fzf below, so forward-word lives on Alt-Right only. Its
        # counterpart keeps both Alt-b and Alt-Left.
        bindkey -M viins "\eb" backward-word
        bindkey -M viins "\e[1;3C" forward-word
        bindkey -M viins "\e[1;3D" backward-word

        # zellij claims Ctrl-T for tab mode (see zellij.nix), so fzf's own binding
        # never reaches zsh. Alt-f is free there; Alt-Shift-f is a separate chord.
        bindkey -M viins "\ef" fzf-file-widget
        bindkey -M vicmd "\ef" fzf-file-widget

        # Last: it wraps the widgets everything above has finished defining.
        source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

        if [[ -z "$ZELLIJ_SESSION_NAME" && "$TERM" == *ghostty* ]]; then
          zellij attach -c $USER@$(hostname)
        fi
      '';

      shellAliases = {
        ls = "eza";
        pn = "pnpm";
        px = "pnpm exec";

        nx = "pnpm nx"; # temporary alias until I figure out dev shells for globals

        k = "kubectl";
        kns = "kubectl config set-context --current --namespace";
      };
    };

    # Integration off because the generated `source <(...)` lands wherever Home
    # Manager puts it, and it must run after the compdefs in initContent.
    # `enable` still puts the binary on PATH for the completer to shell out to.
    carapace = {
      enable = true;
      enableZshIntegration = false;
    };

    atuin = {
      enable = true;
      enableZshIntegration = false;
      forceOverwriteSettings = true;
    };
  };

  # VISUAL stays in sync so tools preferring it do not diverge from EDITOR.
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";

    # Lets `nh darwin switch` run from any directory. No -H needed: `hostname`
    # already matches the darwinConfigurations attr.
    NH_FLAKE = "${config.home.homeDirectory}/.config/nix";

    # sops defaults this to ~/Library/Application Support on darwin and
    # $XDG_CONFIG_HOME on Linux; pinning it keeps one path on both.
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
