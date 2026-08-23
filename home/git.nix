{
  lib,
  vars,
  ...
}: {
  # git only reads the generated ~/.config/git/config when ~/.gitconfig is
  # absent. https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;

      # Stylix has no delta target. It reads bat's theme registry, so naming
      # the theme stylix generates for bat keeps diffs in the same palette.
      options.syntax-theme = "base16-stylix";
    };

    git = {
      enable = true;
      lfs.enable = true;

      settings = {
        rerere.enabled = true;
        user.email = vars.userEmail;
        user.name = vars.fullName;

        init.defaultBranch = "main";

        credential.helper = "store";

        push.autoSetupRemote = true;
        push.default = "current";

        core = {
          # `true` is the Windows setting: it rewrites LF to CRLF in the working
          # tree, corrupting the shebang of any checked-out shell script
          # (`env: bash\r: No such file or directory`).
          autocrlf = "input";
          longpaths = true;
        };

        log.date = "iso";

        alias = {
          br = "branch";
          co = "checkout";
          st = "status";
          sq = "!f() { \
      		let a=$1-1; \
		      c=$(git log --format='%h' HEAD~$a -1); \
		      message=$(git log --format='%s' $c -1); \
		      git reset --soft $c^; \
		      git commit -m $\"$message\"; \
	      }; f";
          ls = "log --format='%C(auto) %h %<(14)%aN %<(14)%C(cyan)%cd%C(auto) %s %d' --date=relative -20";
          lbr = "branch --sort=-committerdate";
          ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
          cm = "commit -m";
          cne = "commit --amend --no-edit";
          pf = "push -f";
        };
      };
    };
  };
}
