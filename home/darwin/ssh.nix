{config, ...}: {
  # home/ssh.nix owns ~/.ssh/config, so the colima include has to be restated
  # here or the runners lose the docker socket. Includes are emitted above every
  # Host block, so colima's values still win.
  programs.ssh.includes = ["${config.home.homeDirectory}/.colima/ssh_config"];
}
