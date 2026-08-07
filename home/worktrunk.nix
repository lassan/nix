_: {
  programs.worktrunk = {
    enable = true;
    enableZshIntegration = true;
  };

  # The upstream home-manager module exposes no config.toml settings, so write
  # the user config file directly. https://worktrunk.dev/config/
  xdg.configFile."worktrunk/config.toml".text = ''
    worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"
  '';
}
