{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Atuin owns Ctrl-R, but it doesn't back zsh's own history list -- up-arrow,
    # `!!`, `!$`, `^foo^bar` and `fc` all still read $HISTFILE. These settings
    # are for that half.
    #
    # ignoreSpace is the one that earns its place regardless: prefixing a
    # command with a space keeps it out of the file entirely, which is the
    # escape hatch when a token ends up on the command line.
    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };
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

      # Carapace ships completion specs for ~650 commands and compdefs all of
      # them unconditionally -- including every command that already has an
      # owner. Two kinds of owner, and carapace is the worse choice for both:
      #
      #   - zsh's own bundled completers. `_git` knows your branches, `_make`
      #     parses the Makefile, `_tar` lists the archive, `_sudo` completes
      #     the command *after* it. None of that survives a static spec. And
      #     carapace's coreutils specs are generated from GNU man pages, so on
      #     darwin they offer flags BSD `ls`/`cp`/`date`/`sed` don't have.
      #   - completers the tool itself installs into site-functions. docker,
      #     gh, just, nix, flyctl, bun, rg, fd and ~15 others land here via
      #     nixpkgs, versioned with the binary they complete -- three of them
      #     (gh, flyctl, docker) were on the list of things carapace was
      #     supposed to fix here, and already had first-party coverage.
      #     Carapace's specs are a snapshot baked into its own release.
      #
      # So carapace fills gaps and never displaces: snapshot what compinit
      # found (plus the two compdefs above), source carapace, then hand back
      # every command that already had an owner. Doing it by diff rather than
      # by CARAPACE_EXCLUDES means the list can't rot -- install a tool that
      # brings its own completer and carapace steps aside on the next rebuild.
      #
      # 213 of the 646 get handed back. What's left is the 433 CLIs nothing
      # else covered: kubectl, pulumi, doctl, terraform, glab, aws, helm, k9s,
      # jj, pnpm, restic, op, task, vercel, turbo, deno, trivy.
      typeset -A _comps_before
      _comps_before=("''${(@kv)_comps}")
      source <(${lib.getExe config.programs.carapace.package} _carapace zsh)
      for _c in "''${(@k)_comps_before}"; do
        [[ ''${_comps[$_c]} == _carapace_completer ]] && _comps[$_c]=''${_comps_before[$_c]}
      done
      unset _comps_before _c

      # By default zsh-vi-mode appends zvm_init to precmd_functions, so it
      # initializes at the first prompt -- i.e. after everything else in this
      # file -- and overwrites their keybindings on the way past. Working around
      # that meant funnelling every plugin and bindkey through zvm's
      # zvm_after_init_commands / zvm_after_lazy_keybindings_commands hooks,
      # which coupled unrelated config to zvm and hid a real bug: the lazy hook
      # only fires on the first entry into normal mode, so Alt-t and friends
      # were undefined-key until you happened to press Escape.
      #
      # ZVM_INIT_MODE=sourcing runs zvm_init at source time instead. Everything
      # below is then plain zsh startup -- source a plugin, bind a key, in the
      # order written -- and nothing needs to know zvm exists. The only rule
      # left is the ordinary one: load after the thing you intend to override.
      ZVM_INIT_MODE=sourcing
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      eval "$(atuin init zsh)"
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      # Loaded here rather than in fzf.nix so it lands after zvm; only its
      # zstyles live there, and those are read at completion time so their
      # position doesn't matter.
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # Alt-f goes to fzf below, so forward-word lives on Alt-Right only. Its
      # counterpart keeps both Alt-b and Alt-Left.
      bindkey -M viins "\eb" backward-word
      bindkey -M viins "\e[1;3C" forward-word
      bindkey -M viins "\e[1;3D" backward-word

      # fzf binds its file widget to Ctrl-T, but zellij claims that for tab mode
      # (see zellij.nix) so it never reaches zsh. Alt-f is free there too --
      # zellij binds Alt-Shift-f (ToggleFloatingPanes), which is a separate
      # chord and does not swallow this one.
      bindkey -M viins "\ef" fzf-file-widget
      bindkey -M vicmd "\ef" fzf-file-widget

      # Last: it wraps the widgets everything above has finished defining.
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

      if [[ -z "$ZELLIJ_SESSION_NAME" && ( "$TERM" == *kitty* || "$TERM" == *ghostty* ) ]]; then
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

  # Integration is off because the generated `source <(...)` would land in
  # initContent at an order Home Manager picks, and this one has to run after
  # the compdefs above -- see the block in initContent. `enable` is still what
  # puts the binary on PATH, which the completer function needs at runtime: it
  # shells out to bare `carapace` on every TAB.
  programs.carapace = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
    forceOverwriteSettings = true;
  };

  # Was previously inherited rather than chosen -- nothing here set it. This is
  # what `git commit`, `git rebase -i`, zellij's EditScrollback and yazi all
  # open, so it should be deliberate. VISUAL was empty; keep the two in sync so
  # tools that prefer VISUAL don't diverge.
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";

    # Lets `nh darwin switch` (and `nh clean`) run from any directory instead of
    # only from the flake root. The hostname is left to nh's own detection --
    # `hostname` is already "macbook", which matches the darwinConfigurations
    # attr, so there's nothing to disambiguate with -H.
    NH_FLAKE = "${homeDirectory}/.config/nix";
  };
}
