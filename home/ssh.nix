{
  homeDirectory,
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;

    # The implicit defaults emit an eval warning and upstream plans to remove
    # them; every one of them already matched ssh's own built-in default.
    enableDefaultConfig = false;

    # Enabling this module makes home-manager own ~/.ssh/config, which until now
    # held nothing but this line. colima rewrites the included file on every VM
    # start and the runners reach the docker socket through it. Includes are
    # emitted above every Host block, so colima's values still win.
    includes = lib.optional pkgs.stdenv.isDarwin "${homeDirectory}/.colima/ssh_config";

    settings."*" = {
      # Bitwarden serves the ed25519 key that .sops.yaml lists as a recipient.
      # The agent only signs and never exports, so sops still reads the derived
      # identity at ~/.config/sops/age/keys.txt rather than going through this.
      identityAgent = "${homeDirectory}/.bitwarden-ssh-agent.sock";
    };
  };
}
