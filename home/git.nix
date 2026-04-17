{
  lib,
  username,
  useremail,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user.email = useremail;
        user.name = username;

        init.defaultBranch = "main";

        push.autoSetupRemote = true;
        push.default = "current";

        core = {
          autocrlf = true;
          longpaths = true;
          fsmonitor = true;
        };

        log.date = "iso"; # use iso format for date

        alias = {
          # common aliases
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
