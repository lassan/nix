{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  workmux = inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  options.workmux.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.workmux.enable {
    home.packages = [workmux];

    home.file.".config/zsh/completions/workmux.zsh".source = pkgs.runCommand "workmux-zsh-completion" {} ''
      XDG_STATE_HOME="$TMPDIR" ${workmux}/bin/workmux completions zsh > "$out"
    '';

    xdg.configFile."workmux/config.yaml".text = ''
      nerdfont: true
      agent: claude
      mode: window
      worktree_dir: ..
      panes:
        - command: <agent>
          name: agent
          focus: true
        - split: horizontal
          name: shell
    '';
  };
}
