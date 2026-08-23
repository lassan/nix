{config, ...}: let
  # pnpm picks its global bin directory per platform and only reads PNPM_HOME
  # once set, so the value has to track the platform too.
  pnpmHome = "${config.home.homeDirectory}/Library/pnpm";
in {
  home = {
    sessionVariables = {
      PNPM_HOME = pnpmHome;
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    };

    # The second entry is the python.org framework build, which has no Linux
    # counterpart.
    sessionPath = [
      pnpmHome
      "/Library/Frameworks/Python.framework/Versions/3.14/bin"
    ];
  };
}
