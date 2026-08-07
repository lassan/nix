{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;

    # The implicit defaults emit an eval warning and upstream plans to remove
    # them; each already matched ssh's own built-in default.
    enableDefaultConfig = false;

    # This module owns ~/.ssh/config, so the colima include has to be restated
    # here or the runners lose the docker socket. Includes are emitted above
    # every Host block, so colima's values still win.
    includes = lib.optional pkgs.stdenv.isDarwin "${config.home.homeDirectory}/.colima/ssh_config";

    settings."*" = {
      # The agent only signs and never exports, so sops still reads the derived
      # identity at ~/.config/sops/age/keys.txt rather than going through this.
      identityAgent = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    };
  };
}
