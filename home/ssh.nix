{config, ...}: {
  programs.ssh = {
    enable = true;

    # The implicit defaults emit an eval warning and upstream plans to remove
    # them; each already matched ssh's own built-in default.
    enableDefaultConfig = false;

    settings."*" = {
      # The agent only signs and never exports, so sops still reads the derived
      # identity at ~/.config/sops/age/keys.txt rather than going through this.
      identityAgent = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    };
  };
}
