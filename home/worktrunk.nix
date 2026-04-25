{...}: {
  programs.worktrunk = {
    enable = true;
    enableZshIntegration = true;
  };

  # The upstream home-manager module doesn't expose worktree-path (or other
  # config.toml settings), so write the user config file directly.
  # See: https://worktrunk.dev/config/
  xdg.configFile."worktrunk/config.toml".text = ''
    worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"
  '';
}
